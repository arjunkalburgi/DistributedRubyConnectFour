require_relative './room_contracts'
class Room
    include RoomContracts

    def initialize(num_players=2)
        @players = Array.new(num_players)
    end

    def setup_game(game)
        invariant 
        pre_setup_game(game)

        # game isn't really used for game mechanics
        # but more for game info (stats)
        @game = game

        post_setup_game
        invariant
    end

    def end_game_free_room
        invariant 
        pre_end_game_free_room

        # record that info in the database
        
        # clear room
        @players = []
        @game = nil 
        
        post_end_game_free_room
    end

    def is_full? 
        @players.length < @num_players
    end 

end