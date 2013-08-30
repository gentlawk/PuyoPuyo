#==============================================================================#
#                                   human.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Human < FieldController
  def initialize(ipt_ctrl, x, y, row_s, line_s, block_s)
    super(x, y, row_s, line_s, block_s)
    @ipt_ctrl = ipt_ctrl
  end

  def human?; true; end
  def cpu?; false; end

  def update
    @ipt_ctrl.update
    super
  end

  def input_move_row?
    ir = @ipt_ctrl.press?(:right)
    il = @ipt_ctrl.press?(:left)
    return 0 unless ir ^ il
    return ir ? 1 : -1
  end
  def input_rotate_right?
    @ipt_ctrl.press?(:button1)
  end
  def input_rotate_left?
    @ipt_ctrl.trigger?(:button2)
  end
  def input_fastfall?
    @ipt_ctrl.press?(:down)
  end
end
