require_relative './client_contracts'
require_relative './game/game'

class Client < Game
    include ClientContracts    

end