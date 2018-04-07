require_relative './server_contracts'
require_relative './GameRoom/room'

class Server 
    include ServerContracts    
    
    
    def initialize(host, user, password, db, port, number_of_rooms=5)
        pre_initialize(host, user, password, db, port, number_of_rooms)

        @rooms = Array.new(number_of_rooms, nil)

        @host = host
        @user = user
        @password = password
        @db = db
        @port = port
        begin
            @connection = Mysql.new(host, user, password, db, port)
        rescue Mysql::Error => e
            puts e.error
        end
        post_initialize
        invariant
    end

    def enter_room(client, room_number: nil, game: nil)
        # create (room_number==nil) / join room (room_number!=nil)
        invariant 
        pre_enter_room(client)

        if room_number.nil? 
            create_room(client, game)
        else
            join_room(client, room_number)
        end 

        post_enter_room
        invariant 
    end 

    def create_room(client, game)
        invariant 
        pre_create_room

        room_number = rooms.rindex(nil)
        room = @rooms[room_number]
        room = Room.new(game)

        post_enter_room(room_number)
        invariant 
    end 

    def join_room(client, room_number)
        invariant
        pre_join_room 

        room = @rooms[room_number]
        if room.is_full? 
            # reject, room is full pick another 
        elsif room.nil? 
            # reject, must create a room not join a room
        else
            # join
        end 

        post_join_room 
        invariant
    end

    def take_turn(room_number, game_obj)
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
