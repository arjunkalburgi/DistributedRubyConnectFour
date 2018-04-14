require_relative './server'

Server.new('localhost', ARGV[0].to_i)
