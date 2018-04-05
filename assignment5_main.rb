# Project 4

# See test files for execution instructions 

# Group: Winter2018_Group1
#     Bianca Angotti 
#     Andrew McKernan
#     Arjun Kalburgi

# Distributed ConnectFour Application
require 'set'

print "What are you trying to spin up? (client, server, exit)? "
user_input = gets.chomp

while not Set["client","server","exit"].include? user_input
    print "What are you trying to spin up? (client, server, exit)? "
    user_input = gets.chomp
end 

case user_input
when "client"
    require_relative './app/client/client_driver'
when "server"
    require_relative './app/server/server_driver'
else 
    puts "Goodbye"
end 