module ServerContracts

	def invariant
		if !@rooms.nil? 
            raise "RoomError, Rooms must be an array" unless @rooms.kind_of? Array 
            @rooms.each { |room|
                raise "RoomError, Each item in the list of rooms must be of the Room class" unless room.is_a? Room 
            }
        end
	end 

	def pre_initialize(host, user, pwd, db, port)
		# database
		raise "Database Creation Error, host must be String" host.is_a?(String)
        raise "Database Creation Error, user must be String" user.is_a?(String)
        raise "Database Creation Error, pwd must be String" pwd.is_a?(String)
        raise "Database Creation Error, db must be String" db.is_a?(String)
        raise "Database Creation Error, port must be String" port.is_a?(Fixnum)

		# maybe something about socket initalizing? 
	end 
	def post_initialize
        raise "Database Error, no db connection" !@connection.nil?
	end 


	def pre_join_room(client, room_number)
		# room_number
		raise "RoomError, Current room must exist within the range of rooms" unless room_number.between?(0, @rooms.size-1)
	end 
	def post_join_room
		# no contracts
	end 


	def pre_take_turn(room_number, game_obj)
		# room_number
		raise "RoomError, Current room must exist within the range of rooms" unless room_number.between?(0, @rooms.size-1)

		# game obj 
		raise "Server error, game object must be of type Game" unless game_obj.is_a? Game
	end 
	def post_take_turn
		# no contracts
	end 



end