require_relative './server_contracts'
require_relative './GameRoom/room'

class Server 
    include ServerContracts    

    def initialize(host, user, pwd, db, port, number_of_rooms=5)
        pre_initialize(host, user, pwd, db, port)

        @rooms = Array.new(number_of_rooms, Room.new)

        @host = host
        @user = user
        @pwd = pwd
        @db = db
        @port = port
        begin
            @connection = Mysql.new(host, user, pwd, db, port)
        rescue Mysql::Error => e
            puts e.error
        end

        post_initialize
        invariant
    end

    def join_room(client, room_number)
        invariant 
        pre_join_room(client, room_number)

        room = @rooms[room_number]

        if room.is_full?
            # reject
        else 
            if room.players.empty? 
                # join 
                # let this client setuptheroom's play style stuff
                # room.setup_game(game that the user makes) 
            elsif room.is_full? 
                # join 
            end 
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
            room.end_game_free_room
        end

        post_take_turn
        invariant
    end
end