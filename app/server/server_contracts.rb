require_relative '../client/game/player/player'
require_relative '../client/game/game/game'
require_relative './GameRoom/room'

module ServerContracts

	def invariant
		raise "RoomError, Rooms must be a hash" unless @rooms.kind_of? Hash 
        #@rooms.each { |room|
        #    raise "RoomError, Each item in the list of rooms must be of the Room class" unless room.is_a? Room 
        #}
	end 

	def pre_initialize(host, port, number_of_rooms)
		# database
		raise "Database Creation Error, host must be String" unless host.is_a?(String)
        raise "Database Creation Error, port must be Fixnum" unless port.is_a?(Fixnum)
        raise "Number of rooms must be greater than 0" unless number_of_rooms > 0

		# maybe something about socket initalizing? 
	end 
	def post_initialize
        	raise "Database Error, no db connection" unless !@connection.nil?
	end 
 

	def pre_connect(player)
		#currently we're just taking in the username
		#raise "Server Error, player must be a Player" unless player.is_a? Player
	end 
	def post_connect
		# no contracts
	end


	def pre_create_room
		#none
	end 
	def post_create_room(room_id)
		raise "ServerError, Room not created" unless @rooms[room_id].is_a? Room
	end


	def pre_join_room(rn)
		raise "ServerError, room at room_number must be a valid room" unless @rooms[rn].is_a? Room
	end 
	def post_join_room
		# no contracts
	end


	def pre_column_press(room_number)
		# room_number
		raise "RoomError, Current room must exist within the range of rooms" unless room_number.between?(0, @rooms.size-1)

		# game obj 
		#raise "Server error, game object must be of type Game" unless game_obj.is_a? Game
	end 
	def post_column_press
		# no contracts
	end 



end
