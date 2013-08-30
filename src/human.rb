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
    return 0 unless @ipt_ctrl.press?(:right) ^ @ipt_ctrl.press?(:left)
    return 1 if @ipt_ctrl.repeat?(:right)
    return -1 if @ipt_ctrl.repeat?(:left)
    return 0
  end
  def input_rotate?
    # omit input concurrency because 'trigger returns true' is only 1 frame
    return 1 if @ipt_ctrl.trigger?(:button1)
    return -1 if @ipt_ctrl.trigger?(:button2)
    return 0
  end
  def input_fastfall?
    @ipt_ctrl.press?(:down)
  end
  def input_momentfall?
    @ipt_ctrl.press?(:up)
  end
end
