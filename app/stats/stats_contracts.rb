module StatsContracts

    def invariant
    end

    def pre_initialize(host, user, password)
        raise "Database Creation Error, host must be String" unless host.is_a? String
        raise "Database Creation Error, username must be String" unless username.is_a? String
        raise "Database Creation Error, password must be String" unless password.is_a? String
    end

    def post_initialize(connection)
        raise "Database Error, no db connection" unless !@connection.nil?
    end

    def pre_add_game_to_database(game)
        raise "Database Input Error, game must of type Game" unless game.is_a? Game
    end

    def post_add_game_to_database
        # Stat should be added to database
    end

    def pre_get_game(player1, player2, game, winner, is_complete)
        raise "Database Input Error, at least one of player1, player2, game, winner or is_complete must have a value" unless !(player1.nil? and player2.nil? and game.nil? and winner.nil? and is_complete.nil?)
        raise "Database Input Error, game must be of type Game or nil" unless game.is_a? Game or game.nil? 
    end

    def post_get_game(result)
        raise "Database Input Error, result must be an array of Games" unless result.is_a? Array
        result.each { |g|
            raise "Database Input Error, not all elements of the result were games" unless g.is_a? Game
        }
    end

    def pre_get_player_stats(playername)
        raise "Database Input Error, input must be String" unless playername.is_a? String
    end

    def post_get_player_stats(result)
        raise "Database Input Error, result must be String" unless result.is_a? String
    end

    def pre_league_stats
    end

    def post_league_stats(result)
        raise "Database Input Error, result must be String" unless result.is_a? String
    end
end