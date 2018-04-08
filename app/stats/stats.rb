require_relative './stats_contracts'
require 'mysql'

class Stats 
	include StatsContracts    

	def initialize(host, username, password, database)
		invariant 
		pre_initialize(host, username, password, database)

		begin
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

	def add_stat
		invariant 
		pre_add_stat

		post_add_stat
		invariant
	end

    def enter_room(client, room_number: nil, game: nil)
	def get_game(player1: nil, player2: nil, game: nil, winner: nil)
		invariant 
		pre_get_game

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
