require_relative './client_contracts'
require_relative './game/game_controller'

class Client < GameController
    include ClientContracts   

    def connect_with_server 
        invariant 
        pre_connect_with_server

        post_connect_with_server
        invariant
    end 

    def join_game_room
        invariant 
        pre_join_game_room

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
end
