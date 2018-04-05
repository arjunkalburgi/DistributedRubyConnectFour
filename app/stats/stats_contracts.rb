module StatsContracts

    def invariant
    end

    def pre_initialize(host, user, pwd, db, port)
        raise "Database Creation Error, host must be String" host.is_a?(String)
        raise "Database Creation Error, user must be String" user.is_a?(String)
        raise "Database Creation Error, pwd must be String" pwd.is_a?(String)
        raise "Database Creation Error, db must be String" db.is_a?(String)
        raise "Database Creation Error, port must be String" port.is_a?(Fixnum)
    end

    def post_initialize(connection)
        raise "Database Error, no db connection" !@connection.nil?
    end

    def pre_add_stat(game_id, p1, p2, winner)
        raise "Database Input Error, input must be String" game_id.is_a?(String)
        raise "Database Input Error, input must be String" p1.is_a?(String)
        raise "Database Input Error, input must be String" p2.is_a?(String)
        raise "Database Input Error, input must be String" winner.is_a?(String)
    end

    def post_add_stat
        # Stat should be added to database
    end

    def pre_get_game(game_id)
        raise "Database Input Error, input must be String" game_id.is_a?(String)
    end

    def post_get_game(result)
        raise "Database Input Error, result must be String" result.is_a(String)
    end

    def pre_get_player(id)
        raise "Database Input Error, input must be String" game_id.is_a?(String)
    end

    def post_get_player(result)
        raise "Database Input Error, result must be String" result.is_a?(String)
    end

    def pre_league_stats
    end

    def post_league_stats(result)
        raise "Database Input Error, result must be String" result.is_a?(String)
    end
end