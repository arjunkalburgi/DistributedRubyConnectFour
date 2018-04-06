require_relative './server_contracts'
require_relative './GameRoom/room'

class Server 
    include ServerContracts    

    def initialize(number_of_rooms=5)
        pre_initialize

        @rooms = Array.new(number_of_rooms, Room.new)

        post_initialize
        invariant
    end

    def join_room(client, room_number)
        invariant 
        pre_join_room

        room = @rooms[room_number]

        if room.is_full?
            # reject
        else 
            # join 
            if room.is_full? 
                room.setup_game
            end 
        end

        post_join_room
        invariant 
    end 

    def take_turn(room_number, game_obj)
        invariant 
        pre_take_turn

        puts "update game obj in the specified room"

        post_take_turn
        invariant
    end
end