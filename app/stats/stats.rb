require_relative './stats_contracts'
require 'mysql'

class Stats 
	include StatsContracts    

	def initialize(host, username, password, database)
		invariant 
		pre_initialize(host, username, password, database)

		begin
			host = "localhost"
			username = "root"
			password = "password"
			database = "DistributedRubyConnectFour"
			@connection = Mysql.new(host, username, password, database, "")
		rescue Mysql::Error => e
			puts e.error
		end

		if @connection.query("SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='DistributedRubyConnectFour'").any? 
			@connection.query("CREATE DATABASE IF NOT EXISTS DistributedRubyConnectFour;")
		else 
			@connection.query("use DistributedRubyConnectFour")
		end 

		if !@connection.query("show tables").any? 
			@connection.query("CREATE TABLE gamestats (player1 VARCHAR(20), player2 VARCHAR(20),game LONGTEXT, is_complete TINYINT(1), winner VARCHAR(20));")
		end 

		post_initialize
		invariant
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

	def get_game(player1: nil, player2: nil, game: nil, winner: nil, is_complete: nil)
		invariant 
		pre_get_game(player1, player2, game, winnerl, is_complete)

		if !game.nil?
			# search with game
			get_game(player1: game.players[0].player_name, player2: game.players[1].player_name)
		elsif !player1.nil? and !player2.nil? 
			# search with both players
			@connection.query("select game from gamestats where player1 = '#{player1}' and player2 = '#{player2}' or player1 = '#{player2}' or player2 = '#{player1}';")
		elsif player1.nil? and player2.nil? and game.nil? and is_complete.nil?
			# search with winner
		elsif player2.nil? and game.nil? and winner.nil? and is_complete.nil?
			# search with player 1
			@connection.query("select game from gamestats where player1 = '#{player1}' or player2 = '#{player1}';")
		elsif player1.nil? and game.nil? and winner.nil? and is_complete.nil?
			# search with player 2
			@connection.query("select game from gamestats where player1 = '#{player2}' or player2 = '#{player2}';")
		elsif player1.nil? and player2.nil? and game.nil? and winner.nil?
			# search with is_complete 
			@connection.query("select game from gamestats where is_complete = '#{is_complete}';")
		elsif !(player1.nil? and player2.nil? and winner.nil? and is_complete.nil?)
			@connection.query("select game from gamestats where winner = '#{winner}' and is_complete = '#{is_complete}' and ((player1 = '#{player1}' and player2 = '#{player2}') or (player1 = '#{player2}' or player2 = '#{player1}'));")
		# elsif player1.nil? and player2.nil? and game.nil? and winner.nil? and is_complete.nil?
		end 

		post_get_game
		invariant
	end

	def get_player
		invariant 
		pre_get_player

		post_get_player
		invariant
	end

	def get_league_stats
		invariant 
		pre_get_league_stats

		post_get_league_stats
		invariant
	end

end
