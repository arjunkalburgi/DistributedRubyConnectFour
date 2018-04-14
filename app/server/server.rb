require 'xmlrpc/server'
require 'xmlrpc/client'
require_relative './server_contracts'
require_relative './GameRoom/room'
require_relative '../client/game/game/game'
require_relative '../client/game/player/player'
require_relative '../stats/stats'

class Server 
    include ServerContracts    
    
    
    def initialize(host, port, number_of_rooms=5)
        pre_initialize(host, port, number_of_rooms)
		@stats = Stats.new
        @rooms = Hash.new
        @roomComponents = Hash.new
		@clients = Hash.new
		s = XMLRPC::Server.new(port, host, number_of_rooms*2)
		s.add_handler("handler", self)
		s.serve
        
        post_initialize
        invariant
    end

    def connect(player_name, ip_address, port)
        # create (room_number==nil) / join room (room_number!=nil)
        invariant 
        pre_connect(player_name)
		#c = XMLRPC::Client.new(ip_address, "/", port + 1)
		c = XMLRPC::Client.new('localhost', "/", port + 1)
		if !@clients.key?(player_name)
			@clients[player_name] = c.proxy("client")
		else
			return false
		end
		post_connect
		invariant 
		return true
    end 
	
	def disconnect(player_name)
		invariant
		pre_disconnect
		@clients.delete(player_name)
		post_disconnect
		invariant
	end

	#def set_room_name(room_id)
		#@roomComponents[room_id] = Hash.new
	#end

	#def set_room_player1(room_id, serPlayer1)
		#puts @stats.deserialize_item(serPlayer1).class
		#@roomComponents[room_id]["P1"] = @stats.deserialize_item(serPlayer1)
	#end
	
	#def set_room_player2(room_id, serPlayer2)
		#@roomComponents[room_id]["P2"] = @stats.deserialize_item(serPlayer2)
	#end
	
	#def set_room_board(room_id, serBoard)
		#@roomComponents[room_id]["board"] = @stats.deserialize_item(serBoard)
	#end
	
	#def get_room_player1(room_id)
		#return @stats.serialize_item(@rooms.game.players[0])
	#end
	
	#def get_room_player2(room_id)
		#return @stats.serialize_item(@rooms.game.players[1])
	#end
	
	#def get_room_board(room_id)
		#return @stats.serialize_item(@rooms.game.board)
	#end
	
	#def get_room_curr_player_num(room_id)
		#return @rooms.game.current_player_num
	#end
	
	#def get_room_token_limitations(room_id)
		#return @rooms.game.token_limitations
	#end

    def create_room(username, room_id, token_limitations)
        invariant 
        pre_create_room
        #board = @stats.deserialize_item(@roomComponents[room_id]["board"])
        p1 = Player.new(@username, Array.new(4, 'R'))
        p2 = Player.new(@username, Array.new(4, 'Y'))
        player = p1
        rows = 6
        columns = 7
        game = Game.new(rows, columns, [p1, p2], token_limitations)
        #game.board = board
        #player = Player.new(@username, Array.new(4, token))
		#player.player_name = username
		if @rooms.key?(room_id)
			puts "Room already exists"
			return false
		end
		room = Room.new(game)
        room.add_player(player)
		@rooms[room_id] = room
		post_create_room(room_id)
        invariant 
        return true
    end 

    def join_room(username, room_id)
        invariant
        pre_join_room(room_id)
        room = @rooms[room_id]
		new_player_idx = room.players.size
		new_player = room.game.players[new_player_idx]
		new_player.player_name = username
        if room.nil? 
            puts "Room no longer exists - please choose another"
			return
        elsif room.is_full? 
            puts "Room is full - please choose another"
			return
        else
            if room.add_player(new_player)
				return true
            else
				puts "add player failed"
				return false
            end
        end 

        post_join_room 
        invariant
    end

    def get_room_ids()
		return @rooms.keys
	end
	
	def get_num_players_in_room(room_id)
		return @rooms[room_id].players.size
	end
	
	def get_required_players_in_room(room_id)
		# as in the number of players you need to start the game
		return @rooms[room_id].num_players
	end
	
	def can_start_game?(room_id)
		puts get_num_players_in_room(room_id)
		puts get_required_players_in_room(room_id)
		puts @rooms[room_id]
		return get_num_players_in_room(room_id) == get_required_players_in_room(room_id)
	end

    def column_press(room_id, column, token)
        invariant 
        pre_take_turn(room_id, game_obj)
        puts "made it"
        room = @rooms[room_id]
        game_obj = room.game

        begin
			game_obj.play_move(column, token)
		rescue
			# don't do anything, let the clients handle it, we just want to save this new version of game_obj
		end
		
		#TODO: update database with new game object
		
		#update the boards and GUI with this move
        room.players.each { |player|
			puts room.players
			puts @clients.keys
			player.player_name
			puts @clients[player.player_name]
			@clients[player.player_name].column_press(column, token)
        }
        begin
            game.check_game
        rescue *GameError.GameEnd => gameend
            game_over(room_id)
        end

        post_take_turn
        invariant
    end
	
	def game_over(room_id)
		invariant
		pre_game_over
		#remove room from list of rooms
		@rooms.delete(room_id)
		#there is no need to tell the clients, they handle the game 
		#ending with their version of game
		post_game_over(room_id)
		invariant
	end
	
	def save_game()
		
	end
	
	def load_game()
	
	end
end
