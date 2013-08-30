#==============================================================================#
#                           control_block_manager.rb                           #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ControlBlockManager
  def initialize
    init_ctrl_blocks
  end
  def init_ctrl_blocks
    @ctrl_blocks = {
      PivotControlBlock => PivotControlBlock.new,
      CycleControlBlock => CycleControlBlock.new
    }
    @type = PivotControlBlock
  end
  def set_type(type)
    ctrl_block.clear unless @type.nil?
    @type = type
  end
  def ctrl_block
    @ctrl_blocks[@type]
  end
end
