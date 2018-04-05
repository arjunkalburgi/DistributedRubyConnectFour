require_relative './client_contracts'
require_relative './game/game_controller'

class Client < GameController
    include ClientContracts    

end