require_relative './stats_contracts'
require 'mysql'

class Stats 
    include StatsContracts    

  def initialize(host, username, password, database, port)
    invariant 
    pre_initialize(host, username, password, database, port)

    @host = host
    @username = username
    @password = password
    @database = database
    @port = port
    begin
      @connection = Mysql.new(host, username, password, database, port)
    rescue Mysql::Error => e
      puts e.error
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

  def get_game
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
