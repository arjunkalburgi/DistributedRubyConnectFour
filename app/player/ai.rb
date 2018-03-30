require_relative './player'
require_relative './player_contracts'


class AIOpponent < Player
    include PlayerContracts

    attr_reader :difficulty 
    # From player: player_name, player_win_condition, tokens

    def initialize(name, win_condition, diff, available_tokens=nil) 
        # invariant 
        pre_init(win_condition, available_tokens)

        @difficulty = diff
        super(name, win_condition, available_tokens)

        post_init
        invariant         
    end

    def choose_column(board, players, player_num, token=nil)
        invariant 
        pre_choose_column(board, players, player_num)
        old_board = board.dup

        # shuffle players array so that current player is first 
        players = shuffle_players_list(players, player_num)

        if token.nil?
            if !@available_tokens.nil? 
                token = @available_tokens.sample
            else 
                token = @tokens.sample
            end 
        end 

        # returns a column 
        column = minimax(board, @difficulty, token, players)[1]

        post_choose_column(column, board, old_board)
        invariant         

        column
    end

    private 

    def minimax(board, depth, token, players, player_num=nil)
        invariant
        pre_minimax(board, depth, players, player_num=nil)

        if depth == 0
            return [0, board.available_columns.sample] 
        elsif board.available_columns == []
            return [0, 0]
        end 

        if player_num.nil? or players.size-1 == player_num
            player_num = 0  
        else
            player_num += 1
        end

        thread_list = []
        available_moves = Array.new(board.available_columns.size, -100)
        board.available_columns.each { |i|
            thread_list << fork do 
                Thread.new do 
                    boardclone = Marshal.load( Marshal.dump(board) )
                    boardclone.add_piece(i, token)
                    available_moves[i] = valueof(boardclone, players.map(&:player_win_condition)) + minimax(boardclone, depth-1, token, players, player_num)[0]
                end
            end 
        }
        thread_list.each { |thread| Process.wait(thread) }

        # randomize if multiple max's 
        best_columns = available_moves.each_index.select{|i| available_moves[i] == available_moves.max}    
        [available_moves.max, best_columns.sample]
    end

    def shuffle_players_list(players, num)
        invariant 
        pre_shuffle_players_list(players, num)

        if num == 0
            r = players 
        else 
            r = players[num..players.size] + players[0..num-1]
        end

        post_shuffle_players_list(r)
        invariant 

        r 
    end

    def valueof(board, players_win_conditions)
        invariant 
        pre_valueof(board, players_win_conditions)

        calculated_value = 0 
        combinations = board.get_all_combinations_of_length(players_win_conditions[0].size)

        players_win_conditions.each_with_index { |cond, i| 
            if i == 0
                m = 1
            else 
                m = -1
            end 

            if combinations.include? cond
                # if other player will win, mark it higher 
                if cond == @player_win_condition 
                    calculated_value += 1*m
                else 
                    calculated_value += 2*m
                end                     
            elsif combinations.include? ([nil] + cond[1..cond.size])
                calculated_value += 0.5*m
            elsif combinations.include? (cond[0..cond.size-1] + [nil])
                calculated_value += 0.5*m
            # elsif combinations.include? ([0, 0] + cond[2..cond.size])
                # calculated_value += 0.3*m
            # elsif combinations.include? (cond[0..cond.size-2] + [0, 0])
                # calculated_value += 0.3*m
            else 
                calculated_value += 0
            end 
        }

        post_valueof(calculated_value)
        invariant

        calculated_value
    end
end 