require_relative './room_contracts'
require_relative '../../client/game/game/game'
class Room
    include RoomContracts
	attr_reader :players, :num_players
	attr_accessor :game
    def initialize(game, num_players=2)
        @players = []
        @num_players = num_players
	@game = game
    end
    
    def get_game_info()
		invariant
		pre_get_game_info()
		# query both players as to what game type they want, create a
		# game object and then return it
		# TODO: set game to real game object
		game = nil
		post_get_game_info(game)
		invariant
		return game
    end
    
    def add_player(player)
		invariant
		pre_add_player(player)
		old_len = @players.length
		if @players.length == @num_players
			# trying to join a full room, tell them no and then kick em out
			return false
		end
		@players << player
		post_add_player(old_len, @players.length)
		invariant
		return true
    end

    def end_game_free_room
        invariant 
        pre_end_game_free_room

        # record that info in the database
        
        # clear room
        @players = []
        @game = nil 
        
        post_end_game_free_room
        invariant
    end

    def is_full? 
		invariant
		pre_is_full
        @players.length == @num_players
        post_is_full
        invariant
    end 

end
