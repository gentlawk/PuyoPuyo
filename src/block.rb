#==============================================================================#
#                                   block.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Block
  attr_accessor :color, :row, :line
  def initialize(col)
    @color = col
    @row = -1
    @line = -1
  end

  def inspect
    sprintf("|(%2d,%2d):%s|",@row,@line,@color.to_s)
  end

  def to_s
    sprintf("|(%2d,%2d):%s|",@row,@line,@color.to_s)
  end
end
