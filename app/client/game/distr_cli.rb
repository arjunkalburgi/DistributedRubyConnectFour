require_relative './game/game'
require_relative './game/game_error'
require_relative '../../server/GameRoom/room'
require_relative '../../stats/stats'
require 'xmlrpc/server'
require 'xmlrpc/client'
require 'set'

class CLI_Game
    def column_press(column, token)
        begin
                @g.play_move(column, token)
            rescue *GameError.GameEnd => gameend
                if gameend.is_a? GameWon
                    puts "Congratulations, we have a winner"
                    puts gameend.player.player_name + " won with the combination: " + gameend.player.player_win_condition.to_s
                    puts @g.board.print_board
                elsif gameend.is_a? NoMoreMoves
                    puts "There are no more possible moves."
                    puts @g.board.print_board
                    puts "It's a cats game!."
                end
            rescue *GameError.TryAgain => slip
                if slip.is_a? NotAValidColumn
                    puts "Column number: " + slip.column.to_s + " is not valid." 
                end 
                puts slip.message
                @g.reset_current_player(current_player)
                puts current_player.player_name + " please play again."
            rescue *GameError.Wrong => error 
                puts "Something went wrong sorry"
                puts error.message
                exit
            end
    end

    def game_loop(port_num=50500)
		@stats = Stats.new
        @port_num = port_num
        Thread.new {
			s = XMLRPC::Server.new(@port_num + 1, 'localhost', 2)
			s.add_handler("client", self)
			s.serve
			exit
		}
        @user_input = nil
		sleep(1)
        puts "Distributed Connect 4 CLI. For now, you must play online."
    
        s = XMLRPC::Client.new('localhost', "/", @port_num)
        @server = s.proxy("handler")
		@server.get_room_ids
        @username = ""
        while @username == ""
            print "Enter a username: "
            @username = gets.chomp
            if !@server.connect(@username, Socket.ip_address_list[1].ip_address, @port_num)
                @username = ""
                print "That username is taken, try again."
            end
        end
    
        create_join = nil
    
        while not Set["j","c"].include? create_join
            print "Would you like to create a room (c), or join a room (j)?: "
            create_join = gets.chomp
        end
    
        @available_rooms = @server.get_room_ids
    
        room_name = ""
    
        while room_name == ""
			puts "Current Rooms:"
			puts @available_rooms.to_s
            print "Enter a room name: "
            room_name = gets.chomp
            if @available_rooms.include?(room_name) && create_join == 'c'
                room_name = ""
                puts "Room name is taken, please try another one."
            elsif !@available_rooms.include?(room_name) && create_join == 'j'
				room_name = ""
				puts "Room does not exist, please try another one."
            end
        end
        if create_join == "c"
            #print "Number of Columns: "
            #columns = gets.chomp.to_i
            columns = 7
            #print "Number of Rows: "
            #rows = gets.chomp.to_i
            rows = 6
            #while not Set["1","2"].include? user_input
            #    print "How many players? 1 or 2: "
            #    user_input = gets.chomp
            #end 
            #num_players = user_input.to_i
            num_players = 2   
            #user_input = nil
            #while not Set["1","2"].include? user_input
            #    print "Would you like to play OTTO/TOOT(1) or ConnectFour(2) style? 1 or 2: "
            #    user_input = gets.chomp
            #end 
            user_input = 2
            style = user_input
            if style == "1"
                token_limitations = true
            else 
                token_limitations = false 
            end
           
            if token_limitations
                puts name + " is playing for OTTO"
                p1 = Player.new(@username, ["O","T","T","O"], ["O", "O", "O", "O", "O", "O", "T", "T", "T", "T", "T", "T"]) 
            else
                #print "P1 - Length of win condition? "
                #num_token = gets.chomp.to_i
                num_token = 4
                #print "P1 - What is your token? "
                #token = gets.chomp
                token = 'R'
                p1 = Player.new(@username, Array.new(num_token, token)) 
            end
            if token == 'R'
                token2 = 'Y'
            else
                token2 = 'R'
            end
            p2 = Player.new("P2", Array.new(num_token, token2))
    
            #if num_players == 1
            #    if token_limitations
            #       p2 = AIOpponent.new("AIOpponent", ["T", "O", "O", "T"], 3, ["O", "O", "O", "O", "O", "O", "T", "T", "T", "T", "T", "T"])
            #    else
            #        print "What do you want the AI token to be? "
            #        token = gets.chomp
            #        p2 = AIOpponent.new("AIOpponent", Array.new(num_token, token), 3)
            #    end
            #else 
            #    #wait for the other player to connect
            #end 
            @g = Game.new(rows, columns, [p1, p2], token_limitations)
            #p1Ser = @stats.serialize_item(p1)
            #p2Ser = @stats.serialize_item(p2)
            #board = @stats.serialize_item(@g.board)
            #curr_player_num = @g.current_player_num
            #@server.set_room_name(room_name)
            #@server.set_room_board(room_name, board)
            #@server.set_room_player1(room_name, p1Ser)
            #@server.set_room_player2(room_name, p2Ser)
            @server.create_room(@username, room_name, token_limitations)
        else
            if @server.join_room(@username, room_name)
				#board = @stats.deserialize_item(@server.get_room_board(room_name))
				p1 = Player.new("P1", Array.new(4, 'R'))
				p2 = Player.new("P2", Array.new(4, 'Y'))
				@username = "P2"
				
				@g = Game.new(6, 7, [p1, p2], false)
				#@g.board = board
				#@g.current_player_num = curr_player_num
			else
				puts "Couldn't join room, sorry"
				return
            end
        end
    
		puts "Waiting for other players to join room..."
        while !@server.can_start_game?(room_name)
            # don't spam the server
            sleep(1)
        end


        while true
            puts @g.board.print_board

            current_player = @g.get_current_player
            #puts @g.players[0].player_name
            #puts @g.players[0].player_name
            if @g.get_current_player.player_name != @username
                print "Please wait for the other player to take their turn."
                while current_player.player_name != @username
                    # do nothing
                    
                end
                next
            end
            #if current_player.is_a? AIOpponent
            #    puts current_player.player_name + "'s turn"
            #    column = nil
            #else 
            token = nil
            if token_limitations
                while not Set["O","T"].include? token
                    print "Would you like to place O or T: "
                    token = gets.chomp
                end 
            end
            print @g.get_current_player.player_name + ", what column number would you like to input your token into: " 
            column = gets.chomp.to_i - 1
            #end 
            @server.column_press(room_name, column, @g.get_current_player.player_win_condition[0])
			
        end 

        puts "Wanna play again?"
    end
end
#puts ARGV[0].to_i
game = CLI_Game.new
game.game_loop(ARGV[0].to_i)
