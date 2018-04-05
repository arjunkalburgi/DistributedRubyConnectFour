require_relative './gui/gui'
require_relative './game/game'
require_relative './game/game_error'
require_relative './game_controller_contracts'

class GameController
	include GameControllerContracts
    attr_reader :game, :gui, :type, :num_players, :current_player

    def initialize
		pre_initialize
        @gui = GUI.new(self)
		invariant
		post_initialize
    end

    def column_press(column, value, gui)
		pre_column_press
		invariant
        current_player = @game.players[@game.current_player_num]
        begin
            @game.play_move(column, value)
            @game.play_move if num_players == "1"
        rescue *GameError.GameEnd => game_end
            if game_end.is_a? GameWon
                puts "Congratulations, we have a winner"
                puts game_end.player.player_name + " won with the combination: " + game_end.player.player_win_condition.to_s
                gui.show_winner(game_end.player.player_name + " won!")
            else
                puts "There are no more possible moves. It's a cats game!"
                gui.show_winner("No winner")
            end
            return
        rescue *GameError.TryAgain => slip
            if slip.is_a? NotAValidColumn
                slip.column ? (puts "Column number: " + slip.column.to_s + " is not valid.") : (puts "Column number is not valid.")
            elsif slip.is_a? NotAnAvailableToken
                puts slip.message
            end
            @game.reset_current_player(current_player)
            puts current_player.player_name + " please try your move again."
            gui.show_error(slip.message + "\n"+ current_player.player_name + " please try your move again.")
            return
        rescue *GameError.Wrong => error 
            puts "Something went wrong sorry"
            puts error.message
            gui.show_error(error.message,true)
            return
        end  
        post_column_press
		invariant
    end

    def setup_game(rows, columns, type, num_players, player_names)
		pre_setup_game
		invariant
        player_names[0].empty? ? name1 = "Player1" : name1 = player_names[0]
        player_names[1].empty? ? name2 = "Player2" : name2 = player_names[1]
        red_yellow = [["R", "R", "R", "R"],["Y", "Y", "Y", "Y"]]
        otto_toot = [["O", "T", "T", "O"],["T", "O", "O", "T"]]
        available_tokens = ["O", "O", "O", "O", "O", "O", "T", "T", "T", "T", "T", "T"]

        @num_players = num_players

        if type == "Connect4"
            p1 = Player.new(name1, red_yellow[0])
            if num_players == "1"
                p2 = AIOpponent.new(name2, red_yellow[1], 3)
            end
            token_limitations = false
        else
            p1 = Player.new(name1, otto_toot[0], available_tokens.clone) 
            if num_players == "1"
                p2 = AIOpponent.new(name2, otto_toot[1], 3, available_tokens.clone)
            end
            token_limitations = true
        end

        @game = Game.new(rows, columns, [p1,p2], token_limitations, true)
  	  	invariant
	  	post_setup_game
    end

    def subscribe(observer)
		pre_subscribe
		invariant
        @game.add_observer(observer)
		invariant
		post_subscribe
    end
end