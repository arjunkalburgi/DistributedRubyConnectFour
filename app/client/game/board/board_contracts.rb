
module BoardContracts

    def invariant 
        raise GameError, "Board must be an array" unless @game_board.is_a? Array
        raise GameError, "Board size should be greater than 0" unless @game_board.size == @rows
        @game_board.each { |e|
            raise GameError, "Board row must be an array" unless e.is_a? Array
            raise GameError, "Board row size should be greater than 0" unless e.size == @columns
        }
    end 
    
    def pre_init(rows, columns)
        raise GameError, "Rows must be a number" unless rows.is_a? Integer
        raise GameError, "Columns must be a number" unless columns.is_a? Integer
        raise GameError, "Number of rows must be greater than 0" unless rows > 0 
        raise GameError, "Number of columns must be greater than 0" unless columns > 0
    end 

    def post_init
        raise GameError, "Board must be an array" unless @game_board.is_a? Array
        raise GameError, "Board size should be equal to the given row size" unless @game_board.size == @rows
        @game_board.each { |e|
            raise GameError, "Board row size should be equal to the given column size" unless e.size == @columns
            e.each { |token|
                raise GameError, "Board tokens must all be initally set to nil" unless token == nil
            }
        }
    end
        
    def pre_can_add_to_column(column_number)
        raise NotAValidColumn.new(column_number, "Column index must be an Integer") unless column_number.is_a? Integer
        raise NotAValidColumn.new(column_number, "Column index must be within range") unless column_number.between?(0, @columns-1)
        raise NotAValidColumn.new(column_number, "Column is full") unless @game_board[0][column_number].nil?
    end

    def post_can_add_to_column
        # no condition necessary
    end

    def pre_available_columns
        # no condition necessary
    end

    def post_available_columns
        # no condition necessary
    end 

    def pre_add_token(column_number)
        raise NotAValidColumn.new(column_number, "Column index must be an Integer") unless column_number.is_a? Integer
        raise NotAValidColumn.new(column_number, "Column index must be within range") unless column_number.between?(0, @columns-1)
    end

    def post_add_token(column_number, token)
        placement = false
        @game_board.each{ |row|
            if row[column_number] == token
                placement = true
                break
            end
        }
        raise GameError, "Token was not properly placed" unless placement
    end

    def pre_is_full
        # no condition necessary
    end

    def post_is_full
        # no condition necessary
    end

    def pre_row(row_number)
        raise IncorrectInput.new("Row index must be either a Range or Integer", {row: row_number}) unless row_number.is_a?(Range) || row_number.is_a?(Integer)
        if row_number.is_a? Range
            row_number.each{ |r|
                raise IncorrectInput.new("Row index must be an Integer", {row: row_number}) unless r.is_a? Integer
                raise IncorrectInput.new("Row index must be within range", {row: row_number}) unless r.between?(0, @rows-1)
            }
        elsif row_number.is_a? Integer
            raise IncorrectInput.new("Row index must not be negative", {row: row_number}) unless row_number.between?(0, @rows-1)
        end 
    end

    def post_row
        # no condition necessary
    end

    def pre_col(column_number)
        raise IncorrectInput.new("Column index must be either a Range or Integer", {column: column_number}) unless column_number.is_a?(Range) || column_number.is_a?(Integer)
        if column_number.is_a? Range
            column_number.each{ |c|
                raise IncorrectInput.new("Column index must be an Integer", {column: column_number}) unless c.is_a? Integer
                raise IncorrectInput.new("Column index must be within range", {column: column_number}) unless c.between?(0, @columns-1)
            }
        elsif column_number.is_a? Integer
            raise IncorrectInput.new("Column index must be within range", {column: column_number}) unless column_number.between?(0, @columns-1)
        end 
    end

    def post_col
        # no condition necessary
    end

    def pre_brackets(row_number, column_number)
        raise IncorrectInput.new("Rows must be a number", {row: row_number, column: column_number}) unless row_number.is_a? Integer
        raise IncorrectInput.new("Columns must be a number", {row: row_number, column: column_number}) unless column_number.is_a? Integer
        raise IncorrectInput.new("Number of rows must be greater than 0", {row: row_number, column: column_number}) unless row_number.between?(0, @rows-1)
        raise IncorrectInput.new("Number of columns must be greater than 0", {row: row_number, column: column_number}) unless column_number.between?(0, @columns-1)
    end

    def post_brackets
        # no condition necessary
    end

    def pre_print_board
        # no condition necessary
    end

    def post_print_board(line)
        raise "Line printed not available" unless line.size > 0
    end

    def pre_clear_board 
        # no condition necessary
    end

    def post_clear_board 
        @game_board.each { |e|
            raise "Board row size should be equal to the given column size" unless e.size == @columns
            e.each { |token|
                raise "Board tokens must all be cleared to nil" unless token == nil
            }
        }
    end

    def pre_each
        # no condition necessary
    end

    def post_each
        # no condition necessary
    end

    def pre_each_with_index
        # no condition necessary
    end

    def post_each_with_index(row_index, column_index)
        raise GameError, "row_index must be between 0 and the max number of rows" unless row_index.between?(0, @rows-1)
        raise GameError, "column_index must be between 0 and the max number of columns" unless column_index.between?(0, @columns-1)
    end

    def pre_get_all_combinations_of_length
        # no condition necessary
    end

    def post_get_all_combinations_of_length
        # no condition necessary
    end

    def pre_get_diagonal_combinations_of_length
        # no condition necessary
    end 

    def post_get_diagonal_combinations_of_length
        # no condition necessary
    end

end