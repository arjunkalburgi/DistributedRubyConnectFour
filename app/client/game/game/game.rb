require_relative './game_contracts'
require_relative './game_error'

require_relative '../board/board'
require_relative '../player/player'
require_relative '../player/ai'


class Game 
    include GameContracts
    attr_reader :board, :current_player_num, :token_limitations
	attr_accessor :players
    def initialize(rows=nil, columns=nil, players=nil, token_limitations=false, debug=false)
        pre_init(rows, columns, players)

        @observers = []
        @token_limitations = token_limitations
        @debug = debug
        set_game_dimensions(rows, columns)
        set_game_players(players)

        post_init
        invariant
    end

    def print_state 
        curr_player = @players[@current_player_num]
        @players.each { |p| 
            if p == curr_player
                puts "The current player: " + p.to_s
            end 
        }

        puts @board.print_board
    end 


    def get_current_player
        invariant 
        pre_get_current_player
        
        player = @players[@current_player_num]
        
        post_get_current_player
        invariant 

        player
    end

    def reset_current_player(player)
        index = @players.rindex(player)

        @current_player_num = index
    end 

    def play_move(column=nil,token=nil)
        invariant 
        current_player = @players[@current_player_num]
        token = current_player.tokens.sample if token.nil? 
        pre_play_move(token)

        beforeboard = Marshal.load( Marshal.dump(@board) )

        if current_player.is_a? AIOpponent
            column = current_player.choose_column(@board, @players, @current_player_num, token)
        end

        row = @board.add_piece(column, token)

        if @token_limitations 
            current_player.available_tokens.delete_at(current_player.available_tokens.index(token))
        end 

        @observers.each{|o| o.update_token(column,row,token)}

        check_game(current_player) 

        debug_print if @debug

        increment_player        

        post_play_move(beforeboard)
        invariant 

        return row
    end

    def add_observer(view)
        @observers << view
    end

    private

    def debug_print
        puts "----------------"
        puts @players[@current_player_num].player_name + "'s turn"
        puts @board.print_board
        puts "----------------"
    end

    def check_game(current_player)
        invariant
        pre_check_game

        combinations = @board.get_all_combinations_of_length(current_player.player_win_condition.length)
        @players.each { |p|
            if combinations.include? p.player_win_condition
                raise GameWon.new(p)
            end
        }
        if @board.is_full?
            raise NoMoreMoves.new
        end

        post_check_game
        invariant
    end

    def increment_player
        invariant 
        old_num = pre_increment_player

        @current_player_num += 1 
        if @current_player_num >= @players.size
            @current_player_num = 0
        end

        if !(@players[@current_player_num].is_a? AIOpponent)
            @observers.each{|o| o.update_buttons(@players[@current_player_num].tokens[0], @players[@current_player_num].player_name)}
        end

        post_increment_player(old_num)
        invariant 
    end

    def set_game_dimensions(rows, columns)
        invariant 
        pre_set_game_dimensions

        if rows.nil? && columns.nil?
            @board = Board.new(6,7)
        else 
            @board = Board.new(rows,columns)
        end

        post_set_game_dimensions 
        invariant 
    end

    def set_game_players(players)
        invariant 
        pre_set_game_players

        @players = players
        if players.nil? 
            p1 = Player.new("Player1", ["R", "R", "R", "R"]) 
            p2 = AIOpponent.new("Player2", ["Y", "Y", "Y", "Y"], 3)
            @players = [p1, p2]
        end

        @current_player_num = 0

        post_set_game_players 
        invariant 
    end

end 
