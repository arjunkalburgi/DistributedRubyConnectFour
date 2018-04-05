require_relative './board_contracts'
require_relative '../game/game_contracts'
require 'set'

class Board 
    include BoardContracts
    include Enumerable
    attr_reader :game_board, :rows, :columns


    def initialize(rows, columns) 
        pre_init(rows, columns)

        @rows = rows
        @columns = columns
        @game_board = Array.new(@rows){Array.new(@columns)}

        post_init
        invariant
    end

    def can_add_to_column?(column_number)
        invariant
        pre_can_add_to_column(column_number)

        result = false
        if !@game_board[0][column_number]
            result = true
        end

        post_can_add_to_column
        invariant
        return result
    end

    def available_columns
        # list of columns that can have a piece added to it 
        invariant
        pre_available_columns

        result = @game_board[0].each_index.select{|i| @game_board[0][i] == nil}

        post_available_columns
        invariant
        return result
    end 

    def add_piece(column_number, token)
        invariant
        pre_add_token(column_number)

        row_number = nil
        if self.can_add_to_column? column_number
            (0..@rows).each{ |row_index|
                if @game_board[@rows - row_index - 1][column_number] == nil
                    @game_board[@rows - row_index - 1][column_number] = token
                    row_number = @rows - row_index - 1
                    break
                end
            }
        else
            raise IncorrectInput.new("No room to add token")
        end

        post_add_token(column_number, token)
        invariant

        return row_number
    end

    def is_full?
        invariant
        pre_is_full

        result = true
        self.each { |e|
            if !e
                result = false
                break
            end
        }

        post_is_full
        invariant
        return result
    end

    def row(row_number)
        invariant
        pre_row(row_number)

        result = @game_board[row_number]

        post_row
        invariant
        return result
    end

    def col(column_number)
        invariant
        pre_col(column_number)

        # result = @game_board.flatten.select.with_index{|v,i| i % @columns == column_number}
        result = Array.new(@rows)
        (0...@rows).each{|row_index| result[row_index] = self[row_index,i] }

        post_col
        invariant
        return result
    end

    def [](row, column)
        invariant
        pre_brackets(row, column)

        result = @game_board[row][column]

        post_brackets
        invariant
        return result
    end

    def to_s
        invariant

        return @game_board.to_s
    end

    def print_board
        invariant
        pre_print_board

        line = ""
        @game_board.each { |e|
            e.each {|token|
                if !token
                    token = "-"
                end
                line += token.to_s + " "    
            }
            line += "\n"
        }

        post_print_board(line)
        invariant
        return line
    end 

    def clear_board 
        invariant
        pre_clear_board
        
        @game_board = Array.new(@rows){Array.new(@columns)}

        post_clear_board
        invariant
    end

    def each
        invariant
        pre_each
        (0...@rows).each{ |row_index|
            (0...@columns).each {|column_index|
                result = self[row_index, column_index]
                post_each
                invariant
                yield result
            }
        }
    end

    def each_with_index
        invariant
        pre_each_with_index
        (0...@rows).each{ |row_index|
            (0...@columns).each {|column_index|
                result = self[row_index, column_index]
                post_each_with_index(row_index, column_index)
                invariant
                yield result, row_index, column_index
            } 
        }
    end

    def get_all_combinations_of_length(l)
        invariant
        pre_get_all_combinations_of_length

        combinations = Set.new

        # rows 
        @game_board.each { |row_vector|
            (0..row_vector.size-l).each { |i|
                combinations << row_vector[i..i+l-1]
            }
        }

        # columns 
        (0..@game_board[0].size-1).each { |c|
            column_vector = []
            @game_board.each {|row|
                column_vector << row[c]
            }
            (0..column_vector.size-l).each { |i|
                combinations << column_vector[i..i+l-1]
            }
        }

        # diagonals 
        combinations.merge(get_diagonal_combinations_of_length(l))

        post_get_all_combinations_of_length
        invariant
        return combinations
    end

    def get_diagonal_combinations_of_length(l) 
        invariant
        post_get_diagonal_combinations_of_length

        diags = Set.new
        (0..@game_board[0].size - 1).each { |k|
            diags << (0..@game_board.size - 1).collect{|i| @game_board[i][i+k]}
        }
        (0..@game_board[0].size - 1).each { |k|
            diags << (0..@game_board.size - 1).collect{|i| @game_board[i][k-i] if k-i > -1}
        }
        (0..@game_board[0].size - 1).reverse_each { |k|
            diags << (0..@game_board.size - 1).to_a.reverse.collect{|i| @game_board[i][i-k] if i-k > -1}
        }
        (0..@game_board[0].size - 1).reverse_each { |k|
            diags << (0..@game_board.size - 1).to_a.reverse.collect{|i| @game_board[i][k-(i-(@game_board.size-1))]}
        }

        combinations =  Set.new
        diags.each { |d| 
            if d.size > l 
                # break it down 
                (0..d.size-l).each { |i|
                    combinations << d[i..i+l-1]
                }
            elsif d.size == l 
                combinations << d
            end 
        }
        
        post_get_diagonal_combinations_of_length
        invariant
        return combinations
    end


end 