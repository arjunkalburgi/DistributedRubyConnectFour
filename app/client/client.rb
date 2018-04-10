require_relative './client_contracts'
require_relative './game/game_controller'

class Client < GameController
    include ClientContracts   

    attr_reader :available_rooms
    
    def initialize(host, port)
		super()
		s = XMLRPC::Client.new(host, "/", port)
		@server = s.proxy("server")
    end
    
    def connect_with_server(username)
        invariant 
        pre_connect_with_server
		@player_name = username
		#s = XMLRPC::Client.new(host, "/", port)
		#@server = s.proxy("server")
		@available_rooms = @server.get_room_ids
		ip_address = Socket.ip_address_list[1].ip_address
		if (!@server.connect(username, ip_address, port))
			#username exists already
			return false
		end
        post_connect_with_server
        invariant
        return true
    end 

	def client_listener
		#TODO: create listener server for this client so that it can receive commands from the 
		# server
		#ip_address = Socket.ip_address_list[1] # public ip, see https://ruby-doc.org/stdlib-1.9.3/libdoc/socket/rdoc/Socket.html#method-c-ip_address_list
		Thread.new {
			s = XMLRPC::Server.new(port, Socket.ip_address_list[1].ip_address)
			s.add_handler("client", self)
			s.serve
			exit
		}
	end
	
    def join_game_room(player_name, room_id)
        invariant 
        pre_join_game_room

		@server.join_room(player_name, room_id)
		@room_id = room_id
		
        post_join_game_room
        invariant
    end 
    
    def setup_game(rows, columns, type, num_players, player_names, room_id)
        invariant 
        pre_setup_game

		super(rows, columns, type, num_players, player_names)
		# player who created room is index 0 in players
        if num_players == "1"
            # play locally 
			puts "Local play VS AI"
            #@gametype = :local
            #super(rows, columns, type, num_players, player_names)
        elsif num_players == "2"
            # play distributed
			puts "Distributed network play"
            #@gametype = :distributed
			@server.create_room(@player_name, room_id, @game)
        end
		@room_id = room_id
        post_setup_game
        invariant
    end

    def distributed_column_press(column, value)
		# call this biz instead of column_press if you're playing multiplayer online
        invariant 
        pre_column_press
		# if it's not your turn, pressing a column does nothing
		if @player_name != @game.players[@game.current_player_num].player_name
			puts "It is not your turn."
			return false
		end
		if @server.get_num_players_in_room(@room_id) < @server.get_required_players_in_room(@room_id)
			puts "Please wait for the required number of players to join the game."
			return false
		end
		
        @server.column_press(room_id, column, value)
        post_column_press
        invariant
    end
	
	def message
		# recieve a message from the server?? Idk if needed
	end
	
	def game_over
		# end the game
	end
	
	def exit
		#end the client session
		server.disconnect
	end
	
end
