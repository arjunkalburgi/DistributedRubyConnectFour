module RoomContracts

    def invariant
        raise "RoomError, Players must be an array" unless @players.kind_of? Array 
    end

    def pre_initialize
        # no Contracts
	end 
    def post_initialize
        # no Contracts
	end 

	
    def pre_setup_game(game)
        raise "RoomError, game must be a Game" unless game.is_a? Game 
    end 
    def post_setup_game
        # no Contracts
    end 


    def pre_end_game_free_room
        # no Contracts
    end 
    def post_end_game_free_room
        # is room cleared
        raise "Room's players has not been cleared properly" unless @players == []
        raise "Room's game has not been cleared properly" unless @game == nil 
    end 


    def pre_is_full
        # no contracts
    end 
    def post_is_full
        # no contracts
    end 

end