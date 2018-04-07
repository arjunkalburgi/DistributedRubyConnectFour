require_relative '.../client/game/player/player'
require_relative '.../client/game/game/game'
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

	def pre_get_game_info
        # no Contracts
	end
	
	def post_get_game_info(game)
		raise "Game object was not properly initialized" unless game.is_a? Game 
	end
	
	def pre_add_player(player)
		raise "Can only add players to room" unless player.is_a? Player
	end
	
	def post_add_player(old_len, new_len)
		raise "Player not added successfully" unless old_len < new_len
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
