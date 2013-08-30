#==============================================================================#
#                                  player1.rb                                  #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Player1 < Human
  def initialize(x, y, row_s, line_s, block_s)
    super(InputController.new(1), x, y, row_s, line_s, block_s)
  end
end
