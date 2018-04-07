require 'xmlrpc/server'
require 'xmlrpc/client'
require_relative './server_contracts'
require_relative './GameRoom/room'

class Server 
    include ServerContracts    
    
    
    def initialize(host, port, number_of_rooms=5)
        pre_initialize(host, port, number_of_rooms)

        @rooms = Hash.new
	@clients = Hash.new
	s = XMLRPC::Server.new(port, hostname, number_of_rooms*2)
	s.add_handler("handler", self)
	s.serve
        
        post_initialize
        invariant
    end

    def connect(player, ip_address, port)
        # create (room_number==nil) / join room (room_number!=nil)
        invariant 
        pre_connect(player)

	c = XMLRPC::Client.new(ip_addr, "/", port)
	if !@clients.key?(player.player_name)
		@clients[player.player_name] = c.proxy("client")
	else
		return false
	end
        post_connect
        invariant 
	return true
    end 

    def enter_room(player, room_id, game: nil)
	invariant 
	pre_enter_room(player)
	if @rooms.key?(room_id)
	    join_room(player, room_id)
        else
	    # load game into game if it exists
	    # game = loadgame()
            create_room(player, room_id, game)
        end 

        post_enter_room
        invariant 
    end

    def create_room(player, room_id, game)
        invariant 
        pre_create_room

        room = Room.new(game)
	room.add_player(player)
	@rooms[room_id] = room

        post_create_room(room_id)
        invariant 
    end 

    def join_room(player, room_id)
        invariant
        pre_join_room 

        room = @rooms[room_id]
        if room.nil? 
            puts "Room no longer exists - please choose another"
	    return
        elsif room.is_full? 
            puts "Room is full - please choose another"
	    return
        else
            room.add_player(player)
        end 

        post_join_room 
        invariant
    end

    def column_press(room_number, column)
        invariant 
        pre_take_turn(room_number, game_obj)

        room = @rooms[room_number]
        room.game = game_obj
        room.players.each { |client| 
            puts "update all room's players games"
        }
        begin
            game.check_game
        rescue *GameError.GameEnd => gameend
            room = nil
        end

        post_take_turn
        invariant
    end
end
