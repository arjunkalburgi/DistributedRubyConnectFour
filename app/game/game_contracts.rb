require_relative '../player/player'
require_relative '../board/board'
require_relative '../game/game_error'

module GameContracts

    def invariant 
        if !@board.nil? 
            raise GameError, "board must be of the Board class" unless @board.is_a? Board
        end 

        if !@current_player_num.nil? 
            raise GameError, "Current player must exist within the range of players" unless @current_player_num.between?(0, @players.size-1)
            raise GameError, "Players must be an array" unless @players.kind_of? Array 
            @players.each { |player|
                raise GameError, "Each item in the list of players must be of the Player class" unless player.is_a? Player 
            }
        end
    end 


    
    def pre_init(rows, columns, players) 
        if !rows.nil? 
            raise GameError, "Rows must be a number" unless rows.is_a? Integer
            raise GameError, "Number of rows must be greater than 0" unless rows > 0 
        end
        if !columns.nil? 
            raise GameError, "Columns must be a number" unless columns.is_a? Integer
            raise GameError, "Number of columns must be greater than 0" unless columns > 0
        end

        if !players.nil?
            raise GameError, "Given players argument must be an array" unless players.kind_of? Array
            players.each { |player|
                raise GameError, "All players in players argument must be of type Player" unless player.is_a? Player
            }
            players.each { |p|
                raise GameError, "Size of board must be greater than win condition" unless p.player_win_condition.length <= rows && p.player_win_condition.length <= columns
            }
        end
    end
    
    def post_init
        # nothing to do 
    end



    def pre_get_current_player  
        # nothing to do 
    end
    
    def post_get_current_player
        # check player
        p = @players[@current_player_num]
        raise GameError, "Object in players is not of type Player" unless p.is_a? Player
    end



    def pre_play_move(token)
        if @board.is_full?
            raise NoMoreMoves.new
        end

        if @token_limitations 
            player = @players[@current_player_num]
            raise NotAnAvailableToken.new(player, token) unless player.available_tokens.include? token
        end 
    end
    
    def post_play_move(old_board)
        raise GameError, "Board has not changed, something went wrong" unless old_board.game_board != @board.game_board
        if @token_limitations
            is_empty = [false, false]
            (0..@players.size-1).each{|p_index|
                is_empty[p_index] = @players[p_index].available_tokens.empty?
            }
            raise NoMoreMoves.new unless !is_empty.all?
        end
    end

    def pre_check_game
        # nothing to do 
    end

    def post_check_game
        # nothing to do 
    end


    def pre_increment_player 
        @current_player_num
    end
    
    def post_increment_player(old_num) 
        raise GameError, "Incrementing player number did not work properly" unless old_num == @players.size - 1 ? @current_player_num == 0 : @current_player_num - 1 == old_num
    end


    def pre_set_game_dimensions
        # nothing to do 
    end 

    def post_set_game_dimensions
        # nothing to do 
    end 


    def pre_set_game_players
        # nothing to do 
    end 

    def post_set_game_players
        # nothing to do 
    end 



    
end