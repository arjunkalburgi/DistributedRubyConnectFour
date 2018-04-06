require_relative './gui_contracts'
require "gtk3"

class GUI
    include GUIContracts
    attr_reader :window, :game_window, :game_box, :controller, :pictures, :colours, :buttons
	
    def initialize(controller)
        #pre_initialize
        #invariant
		
	@controller = controller
        set_constants
        show_start_menu
        
        #post_initialize
        #invariant
    end
    
    def show_start_menu
        menu_glade = "#{File.expand_path(File.dirname(__FILE__))}/menuLayout.glade"
        game_layout = "#{File.expand_path(File.dirname(__FILE__))}/gameLayout.glade"

	builder = Gtk::Builder.new(:file => menu_glade)
        game_builder = Gtk::Builder.new(:file => game_layout)
		
	@window = builder.get_object("menuWindow")
	@window.signal_connect("destroy") {Gtk.main_quit}
        @window.title = "Connect4"
        @window.set_position(Gtk::WindowPosition::CENTER)

        @game_window = game_builder.get_object("GameWindow")
        @game_box = game_builder.get_object("gameBox")
        @game_window.signal_connect("destroy") {Gtk.main_quit}
        @game_window.title = "Game"
        @game_window.set_position(Gtk::WindowPosition::CENTER)

        @type = builder.get_object("GameTypes")
        @num_players = builder.get_object("NumberPlayers")
        @rowsObject = builder.get_object("Rows")
        @columnsObject = builder.get_object("Columns")
        @players = []
        @players << builder.get_object("Player1")
        @players << builder.get_object("Player2")
		
        quitButton = builder.get_object("QuitButton")
        quitButton.signal_connect("clicked") {Gtk.main_quit}

	startButton = builder.get_object("StartButton")
	startButton.signal_connect("clicked") {generate_board}
		
        @window.show_all
        Gtk.main
    end
    
    def generate_board
	v_box = Gtk::Box.new(:vertical)

        @rows = @rowsObject.value_as_int
        @columns = @columnsObject.value_as_int

        player_names = []
        @players.each{|e|
            player_names << e.text
        }

        if @type.active_text == "Connect4"
            @buttons = create_buttons("R")
            @token = "R"
            v_box.pack_start(@buttons)
            set_button_colors("R")
        else
            v_box.pack_start(create_buttons("O"))
            v_box.pack_start(create_buttons("T"))
        end

        @images = Array.new(@rows){Array.new(@columns)}
        (0..@rows-1).each{|a|
            v_box.pack_end(create_rows(@rows - a - 1))
        }

        begin
            @controller.setup_game(@rows, @columns, @type.active_text, @num_players.active_text, player_names)
            @game_box.add(v_box)
            @game_window.show_all
            @controller.subscribe(self)
            @window.hide
            show_toot_and_otto_help(player_names) if @type.active_text == "TOOT/OTTO"
        rescue => err
            show_error(err.message,false)
            return
        end
    end

    def create_buttons(value)
        button_box = Gtk::Box.new(:horizontal)
        (0..@columns-1).each{|column|
            button = Gtk::Button.new(:label => "#{value}")
            button.signal_connect("clicked") {
                @token ? @controller.column_press(column, @token, self) : @controller.column_press(column, value, self)
            }
            button_box.pack_start(button, :expand => true, :fill => true, :padding => 0)
        }
        return button_box
    end

    def create_rows(row_num)
        h_box = Gtk::Box.new(:horizontal)
        (0..@columns-1).each{|b|
            @images[row_num][b] = Gtk::Image.new(:file => @pictures["E"])
            h_box.add(@images[row_num][b], :expand => true, :fill => true, :padding => 0)
        }
        return h_box
    end

    def show_winner(message)
        # invariant 
        # pre_show_winner
        dialog = Gtk::Dialog.new(
            :title => "Game Over",
            :parent => @game_window,
            :flags => :modal
        )
        dialog.signal_connect("destroy") {Gtk.main_quit}

        msg = Gtk::Label.new(message)
        format_text(msg, "green")
        dialog.child.add(msg)
        dialog.resize(200,20)

        dialog.show_all
        # post_show_winner
        # invariant
    end

    def show_error(message, close_all=false)
        # invariant 
        # pre_show_winner

        dialog = Gtk::Dialog.new(
            :title => "ERROR",
            :parent => @game_window,
            :flags => :modal
        )
        close_all ? dialog.signal_connect("destroy") {Gtk.main_quit} : dialog.signal_connect("destroy") {dialog.close} 
        dialog.set_position(Gtk::WindowPosition::CENTER)

        msg = Gtk::Label.new(message)
        format_text(msg, "red")
        dialog.child.add(msg)

        dialog.show_all
        # post_show_winner
        # invariant
    end

    def update_token(column, row, value)
        @images[row][column].set_file(@pictures[value])
    end

    def update_buttons(value, player)
        if @buttons
            @buttons.each{ |btn|
                btn.set_label("#{value}")
                @token = value
                set_button_color(btn, value)
            }
        end
        @game_window.title = "Game: " + player + "'s turn"
    end

    private

    def set_constants
        @pictures = Hash.new
        @pictures["E"] = "#{File.expand_path(File.dirname(__FILE__))}/assets/E.png"
        @pictures["Y"] = "#{File.expand_path(File.dirname(__FILE__))}/assets/Y.png"
        @pictures["R"] = "#{File.expand_path(File.dirname(__FILE__))}/assets/R.png"
        @pictures["O"] = "#{File.expand_path(File.dirname(__FILE__))}/assets/O.png"
        @pictures["T"] = "#{File.expand_path(File.dirname(__FILE__))}/assets/T.png"
        @colours = Hash.new
        @colours["R"] = {:bkg => "red", :text => "white"}
        @colours["Y"] = {:bkg => "yellow", :text => "black"}
    end

    def set_button_colors(value)
        @buttons.each{ |btn|
            set_button_color(btn, value)
        }
    end

    def set_button_color(button, value)
        css_provider = Gtk::CssProvider.new
        css_provider.load(data: "button {background-color: #{@colours[value][:bkg]}; background-image: none; color: #{@colours[value][:text]};}\
                                button:hover {background-color: #{@colours[value][:bkg]}; background-image: none;}\
                                button:active {background-color: #{@colours[value][:bkg]}; background-image: none;}"
        )
        button.style_context.add_provider(css_provider, Gtk::StyleProvider::PRIORITY_USER)
    end

    def format_text(view, text_color)
        css_provider = Gtk::CssProvider.new
        css_provider.load(data: "label {color: #{text_color}; font-size: 20px;}")
        view.style_context.add_provider(css_provider, Gtk::StyleProvider::PRIORITY_USER)
    end

    def show_toot_and_otto_help(player_names)
        
        dialog = Gtk::Dialog.new(
            :title => "TOOT/OTTO Rules",
            :parent => @game_window,
            :flags => :modal
        )
        dialog.signal_connect("destroy") {dialog.close} 

        message = "Please note that:\n" + player_names[0] + ": must complete OTTO\n" + player_names[1] + ": must complete TOOT\n"
        message += "There are a limited number of tokens. 6 O's and 6 T's per player."
        msg = Gtk::Label.new(message)
        format_text(msg, "blue")
        dialog.child.add(msg)

        dialog.show_all
    end

end
