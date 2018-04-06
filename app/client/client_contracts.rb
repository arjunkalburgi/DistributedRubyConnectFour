module ClientContracts

    def invariant 
        if @gametype is :distributed
            # ensure connection to server 
        else 
            # no invariant
        end 
    end 

    def pre_connect_with_server
    end 

    def post_connect_with_server
    end 

    def pre_join_game_room
    end 

    def post_join_game_room
    end 

    def pre_setup_game
        if @gametype is :distributed
            # ensure 
        else 
            # no pre conditions
        end 
    end 
    def post_setup_game
        if @gametype is :distributed
            # ensure 
        else 
            # no post conditions -board change post conditions are handled by game contracts
        end 
    end 

    def pre_column_press
        if @gametype is :distributed
            # ensure 
        else 
            # many preconditions that could be checked here are already being 
            # checked in other areas of the code, thus there is no need to check
            # them again. 
        end 
    end 

    def post_column_press
        if @gametype is :distributed
            # ensure 
        else 
            # no post conditions
        end 
    end 
end