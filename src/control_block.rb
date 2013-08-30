#==============================================================================#
#                               control_block.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ControlBlock
  def initialize
    init_blocks
  end
  def init_blocks
    @pivot = nil
    @belongs = []
  end

  def set(pivot, *belongs)
    @pivot = pivot
    @belongs = belongs
  end
  
  def blocks
    return [@pivot, *@belongs].compact
  end
end

if __FILE__ == "control_block.rb"
  require "./require.rb"
  ctrl_block = ControlBlock.new
  pivot = Block.new(:r)
  belong = Block.new(:g)
  ctrl_block.set(pivot, belong)
  p ctrl_block.blocks
end
