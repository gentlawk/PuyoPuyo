#==============================================================================#
#                                  player2.rb                                  #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Player2 < Human
  def initialize(x, y, row_s, line_s, block_s)
    super(InputController.new(2), x, y, row_s, line_s, block_s)
  end
end
