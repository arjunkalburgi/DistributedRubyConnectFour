require_relative './stats_contracts'
require 'mysql'

class Stats 
    include StatsContracts    

  def initialize(host, user, pwd, db, port)
    invariant 
    pre_initialize(host, user, pwd, db, port)

    @host = host
    @user = user
    @pwd = pwd
    @db = db
    @port = port
    begin
      @connection = Mysql.new(host, user, pwd, db, port)
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
