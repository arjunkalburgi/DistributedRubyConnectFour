
module PlayerContracts
    def invariant 
        raise GameError, "The Player object is not correct" unless !@player_name.nil? or !@player_win_condition.nil? or !@tokens.nil? 
        raise GameError, "The Player object win_condition is not correct" unless @player_win_condition.is_a? Array and @player_win_condition.size > 1
        raise GameError, "The Player tokens array is not correct" unless @tokens.is_a? Array and @tokens.size > 0
    end 


    def pre_init(w, at)
        raise GameError, "The Player object win_condition is not correct" unless w.is_a? Array and w.size > 1

        if !at.nil? 
            w.uniq.each { |t|
                raise GameError, "The player must have enough tokens to win the game." unless w.count(t) < at.count(t)
            }
        end
    end 

    def post_init
        # nothing to do here
    end 


    def pre_choose_column(b, ps, n)
        # check board 
        raise IncorrectInput.new("Board inputted must be of type board", {board: b, players: ps, players_index: n}) unless b.is_a? Board 
        raise NoMoreMoves, "Board inputted must be playable" unless b.available_columns.size > 0

        # check players 
        raise IncorrectInput.new("Players array inputted must be an array", {board: b, players: ps, players_index: n}) unless ps.is_a? Array
        ps.each { |p| 
            raise IncorrectInput.new("Each element of the players array inputted must be a Player", {board: b, players: ps, players_index: n}) unless p.is_a? Player
        }

        # check num 
        raise IncorrectInput.new("Player number must be an index of players array inputted", {board: b, players: ps, players_index: n}) unless n.between?(0, ps.size-1)
    end 

    def post_choose_column(c, b, b_o) 
        # board 
        raise GameError, "AI should not change the board" unless b.game_board == b_o.game_board

        # column 
        raise GameError, "Column choosen by AI must be a column in the board" unless c.between?(0, b.columns-1)
        raise GameError, "Column choosen by AI must be an available column" unless b.available_columns.include? c
    end 


    def pre_minimax(b, d, p, n) 
        # board
        raise IncorrectInput.new("Board inputted must be of type board", {board: b, depth: d, players: p, players_index: n}) unless b.is_a? Board 
        
        # depth 
        raise GameError, "Depth should not be below 0" unless d > 0
        raise GameError, "Depth should not be above AI's difficulty" unless d <= @difficulty

        # players 
        raise GameError, "Players array inputted must be an array" unless p.is_a? Array
        p.each { |player| 
            raise GameError, "Each element of the players array inputted must be a Player" unless player.is_a? Player
        }
        raise GameError, "The first element of the players array should be the AI itself" unless p[0] == self 

        # number, n is initialized at nil. check when has a value.
        if !n.nil? 
            raise GameError, "Player number must be an index of players array inputted" unless n.between?(0, p.size-1)
        end
    end 

    def post_minimax(a, b)
        raise GameError, "Available moves array must be the same size as the available columns array" unless a.size == b.available_columns.size 
        a.each { |v| 
            raise GameError, "Available moves must have a value at each element" unless v.is_a? Numeric
        }
    end 


    def pre_shuffle_players_list(ps, n)
        # check players 
        raise IncorrectInput.new("Players array inputted must be an array", {board: b, players: ps, players_index: n}) unless ps.is_a? Array
        ps.each { |p| 
            raise IncorrectInput.new("Each element of the players array inputted must be a Player", {board: b, players: ps, players_index: n}) unless p.is_a? Player
        }

        # check num 
        raise IncorrectInput.new("Player number must be an index of players array inputted", {board: b, players: ps, players_index: n}) unless n.between?(0, ps.size-1)
    end 
    
    def post_shuffle_players_list(ps) 
        raise GameError, "The first element of the players array should be the AI itself" unless ps[0] == self 
    end 


    def pre_valueof(b, conds)
        # check board 
        raise IncorrectInput.new("Board inputted must be of type board", {board: b, players: ps, players_index: n}) unless b.is_a? Board 
        raise NoMoreMoves, "Board inputted must be playable" unless b.available_columns.size > 0

        # check conds 
        raise GameError, "Inputted player's win conditions must include AI's own win condition" unless conds.include? @player_win_condition
    end 
    
    def post_valueof(v)
        raise GameError, "AI must calculate a numeric value for the board" unless v.is_a? Numeric
    end 


end 