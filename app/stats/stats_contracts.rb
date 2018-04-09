module StatsContracts

    def invariant
    end

    def pre_initialize(host, user, pwd, db, port)
        raise "Database Creation Error, host must be String" unless host.is_a?(String)
        raise "Database Creation Error, user must be String" unless user.is_a?(String)
        raise "Database Creation Error, pwd must be String" unless pwd.is_a?(String)
        raise "Database Creation Error, db must be String" unless db.is_a?(String)
        raise "Database Creation Error, port must be String" unless port.is_a?(Fixnum)
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
        raise "Database Input Error, game must be of type Game" unless game.is_a? Game
    end

    def post_get_game(result)
        raise "Database Input Error, result must be String" unless result.is_a(String)
    end

    def pre_get_player(id)
        raise "Database Input Error, input must be String" unless game_id.is_a?(String)
    end

    def post_get_player(result)
        raise "Database Input Error, result must be String" unless result.is_a?(String)
    end

    def pre_league_stats
    end

    def post_league_stats(result)
        raise "Database Input Error, result must be String" unless result.is_a?(String)
    end
end