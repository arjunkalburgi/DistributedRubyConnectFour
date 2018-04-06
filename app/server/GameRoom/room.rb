require_relative './room_contracts'
class Room
    include RoomContracts    

    def initialize(num_players=2)
    end
    
    def setup_game(rows, columns, type, num_players, player_names)
        invariant 
        pre_setup_game

        puts "server's setup_game"

        post_setup_game
        invariant
    end

    def end_game_free_room
        invariant 
        pre_end_game_free_room

        # record that info in the database
        # tell players it's ova
        
        @players = []
        @game = nil 
        
        post_end_game_free_room
        invariant 
    end

    def is_full? 
        @players.length < @num_players
    end 

end