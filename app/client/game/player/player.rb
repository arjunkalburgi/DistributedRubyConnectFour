
require_relative './player_contracts'

class Player
    include PlayerContracts
    attr_reader  :player_win_condition, :tokens
    attr_accessor :available_tokens, :player_name

    def initialize(name, win_condition, available_tokens=nil)
        # invariant 
        pre_init(win_condition, available_tokens)

        @player_name = name
        @player_win_condition = win_condition

        @tokens = win_condition.uniq
        @available_tokens = available_tokens

        post_init
        invariant
    end

end
