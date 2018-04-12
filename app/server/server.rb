require 'xmlrpc/server'
require 'xmlrpc/client'
require_relative './server_contracts'
require_relative './GameRoom/room'
require_relative '../client/game/game/game'
require_relative '../stats/stats'

class Server 
    include ServerContracts    
    
    
    def initialize(host, port, number_of_rooms=5)
        pre_initialize(host, port, number_of_rooms)
		@stats = Stats.new
        @rooms = Hash.new
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

		c = XMLRPC::Client.new(ip_address, "/", port + 1)
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

    #def enter_room(player, room_id, game: nil)
		#invariant 
		#pre_enter_room(player)
		#if @rooms.key?(room_id)
			#join_room(player, room_id)
			#else
			## load game into game if it exists
			## game = loadgame()
			#create_room(player, room_id, game)
        #end 
        #post_enter_room
        #invariant 
    #end

    def create_spaghetti_room(username, room_id, game_string)
        invariant 
        #pre_create_room
        game = @stats.deserialize_game(game_string)
        puts game
        puts "Entered create"
        puts game.players
		#player = game.players[0]
		#player.player_name = username
		if @rooms.key?(room_id)
			puts "Room already exists"
			return false
		end
		#puts "E2"
        room = Room.new(game)
        #puts "E3"
		room.add_player(player)
		#puts "E4"
		@rooms[room_id] = room
		#puts "Ended create"
        #post_create_room(room_id)
        invariant 
        return true
    end 

    def join_room(username, room_id)
        invariant
        #pre_join_room 
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
				return @stats.serialize_game(room.game)
            else
				puts "add player failed"
				return false
            end
        end 

        #post_join_room 
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

    def column_press(room_id, column, token=nil)
        invariant 
        pre_take_turn(room_id, game_obj)

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
		#remove room from list of rooms
		@rooms.delete(room_id)
		#there is no need to tell the clients, they handle the game 
		#ending with their version of game
	end
	
	def save_game()
		
	end
	
	def load_game()
	
	end
end
