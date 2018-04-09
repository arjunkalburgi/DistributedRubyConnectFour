require_relative './client_contracts'
require_relative './game/game_controller'

class Client < GameController
    include ClientContracts   

    attr_reader :available_rooms
    def connect_with_server(username, ip_address, port)
        invariant 
        pre_connect_with_server
		
		s = XMLRPC::Client.new(host, "/", port)
		@server = s.proxy("server")
		@available_rooms = s.get_room_ids
		# TODO: connect currently expects a player object, can we pass that in here?
		while (!s.connect(username, ))
		
        post_connect_with_server
        invariant
    end 

	def client_listener
		#TODO: create listener server for this client so that it can receive commands from the 
		# server
	end
	
    def join_game_room
        invariant 
        pre_join_game_room

		#TODO: Figure out args/IP addresses and junk
		#@server.join_room()
		
        post_join_game_room
        invariant
    end 
    
    def setup_game(rows, columns, type, num_players, player_names)
        invariant 
        pre_setup_game

        if num_players == "1"
            # play locally 
            @gametype = :local
            super(rows, columns, type, num_players, player_names)
        elsif num_players == "2"
            # play distributed
            @gametype = :distributed
			# call select_game_mode to setup rules?
            puts "pass to server's setup_game"
        end

        post_setup_game
        invariant
    end

    def column_press(column, value, gui)
        invariant 
        pre_column_press

        if @gametype == :distributed
            puts "pass to server's column_press"
        else 
            super(column, value, gui)
        end 

        post_column_press
        invariant
    end
	
	def select_game_mode
		# set up rules of game? Somehow get this from user?
	end
	
	def exit
		#end the client session
	end
	
	def update_board
		# to be called from server with the listener, to update the client view of board
	end
	
	def message
		# recieve a message from the server?? Idk if needed
	end
	
end
