require_relative './server_contracts'
class Server 
    include ServerContracts    

    def setup_game(rows, columns, type, num_players, player_names)
        invariant 
        pre_setup_game

        puts "server's setup_game"

        post_setup_game
        invariant
    end

    def column_press(column, value, gui)
        invariant 
        pre_column_press

        puts "server's column_press"

        post_column_press
        invariant
    end
end