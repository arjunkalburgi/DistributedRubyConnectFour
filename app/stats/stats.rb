require_relative './stats_contracts'
require 'mysql2'

class Stats 
	include StatsContracts    

	def initialize(host="localhost", username="root", password="password")
		#invariant 
		#pre_initialize(host, username, password)

		#begin
			#database = "DistributedRubyConnectFour"
			#@connection = Mysql.new(host, username, password, database)
		#rescue Mysql::Error => e
			#puts e.error
		#end

		#if @connection.query("SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='DistributedRubyConnectFour'").any? 
			#@connection.query("CREATE DATABASE IF NOT EXISTS DistributedRubyConnectFour;")
		#else 
			#@connection.query("use DistributedRubyConnectFour")
		#end 

		#if !@connection.query("show tables").any? 
			#@connection.query("CREATE TABLE gamestats (player1 VARCHAR(20), player2 VARCHAR(20),game LONGTEXT, is_complete TINYINT(1), winner VARCHAR(20));")
		#end 

		#post_initialize
		#invariant
	end

	def add_game_to_database(game)
		invariant 
		pre_add_game_to_database(game)

		player1 = g.players[0].player_name 
		player2 = g.players[1].player_name 
		serializedgame = Marshal::dump(g)
		is_complete = g.is_complete
		winner = g.winner
		@connection.query("INSERT INTO gamestats (player1, player2, game, is_complete, winner) VALUES ('#{player1}', '#{player2}', '#{serializedgame}', '#{is_complete}', '#{winner}');")

		post_add_game_to_database
		invariant
	end

	def get_game(player1 = nil, player2 = nil, game = nil, winner = nil, is_complete = nil)
		invariant 
		pre_get_game(player1, player2, game, winnerl, is_complete)

		if !game.nil?
			# search with game
			get_game(player1: game.players[0].player_name, player2: game.players[1].player_name)
		elsif !player1.nil? and !player2.nil? 
			# search with both players
			r = @connection.query("select game from gamestats where player1 = '#{player1}' and player2 = '#{player2}' or player1 = '#{player2}' or player2 = '#{player1}';")
		elsif player1.nil? and player2.nil? and game.nil? and is_complete.nil?
			# search with winner
		elsif player2.nil? and game.nil? and winner.nil? and is_complete.nil?
			# search with player 1
			r = @connection.query("select game from gamestats where player1 = '#{player1}' or player2 = '#{player1}';")
		elsif player1.nil? and game.nil? and winner.nil? and is_complete.nil?
			# search with player 2
			r = @connection.query("select game from gamestats where player1 = '#{player2}' or player2 = '#{player2}';")
		elsif player1.nil? and player2.nil? and game.nil? and winner.nil?
			# search with is_complete 
			r = @connection.query("select game from gamestats where is_complete = '#{is_complete}';")
		elsif !(player1.nil? and player2.nil? and winner.nil? and is_complete.nil?)
			r = @connection.query("select game from gamestats where winner = '#{winner}' and is_complete = '#{is_complete}' and ((player1 = '#{player1}' and player2 = '#{player2}') or (player1 = '#{player2}' or player2 = '#{player1}'));")
		# elsif player1.nil? and player2.nil? and game.nil? and winner.nil? and is_complete.nil?
		end 

		games = []
		r.each_hash do |row|
			games << Marshal::load(row['game'])
		end 

		post_get_game(games)
		invariant

		games
	end

	def get_player_stats(playername)
		invariant 
		pre_get_player_stats

		number_of_completed_games = @connection.query("select count(*) from gamestats gamestats WHERE is_complete=1 and (player1 = '#{playername}' or player2 = '#{playername}')").first[0].to_i
		number_of_wins = @connection.query("select count(*) from gamestats gamestats WHERE winner = '#{playername}'").first[0].to_i
		number_of_incomplete_games = @connection.query("select count(*) from gamestats gamestats WHERE is_complete=0 and (player1 = '#{playername}' or player2 = '#{playername}')").first[0].to_i

		if number_of_completed_games == 0 and number_of_wins == 0 and number_of_incomplete_games == 0
			result = "#{playername} has not played any games."
		else 
			result = "#{playername} has finished #{number_of_completed_games} games and won #{number_of_wins} of them. #{playername} has #{number_of_incomplete_games} games unfinished."
		end 
		puts result

		post_get_player_stats
		invariant

		result
	end

	def get_league_stats
		invariant 
		pre_get_league_stats

		r = @connection.query("select winner, count(winner) as wins from gamestats group by winner order by count(winner) desc limit 10")
		topten = []
		index = 1
		r.each_hash do |row|
			topten << "#{index}. #{row['winner']} has won #{row['wins']} games."
			index += 1
		end 

		post_get_league_stats(topten)
		invariant

		topten
	end
	
	def serialize_item(item)
		return Marshal::dump(item)
	end
	
	def deserialize_item(item_string)
		return Marshal::load(item_string)
	end

end
