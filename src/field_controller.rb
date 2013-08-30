#==============================================================================#
#                             field_controller.rb                              #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class FieldController
  def initialize(x,y,row_s, line_s, block_s)
    @x = x; @y = y
    @colors = [:r, :g, :b, :y]
    @row_s = row_s; @line_s = line_s; @block_s = block_s
    init_field
    init_phase
  end
  def init_field
    @field = Field.new(@row_s, @line_s, @block_s)
  end
  def init_phase
    @phase = Phase.new
    # added :control_block handler
    @phase.add_start_handler(:control_block,
                             method(:start_control_block))
    # added :falldown handler
    @phase.add_condition_handler(:falldown,
                                 :eliminate,
                                 method(:falldown_eliminate_cond))
    # added :elimiate handler
    @phase.add_condition_handler(:eliminate,
                                 :falldown,
                                 method(:eliminate_falldown_cond))
    @phase.add_condition_handler(:eliminate,
                                 :control_block,
                                 method(:eliminate_control_block_cond))
    @phase.change :control_block
  end
  def update
    update_blocks
    draw_field
    return if @phase.waiting
    case @phase.phase
    when :phase_trans
      @phase.trans_condition_check
    when :control_block
      update_control_block
    when :falldown
      update_falldown
    when :eliminate
      update_eliminate
    end
  end
  
  def start_control_block
    @field.start_control_block(@colors)
  end
  
  def update_control_block
    inputs = [input_move_row?,input_rotate?,input_fastfall?]
    active = @field.update_control_block(*inputs)
    @phase.change :falldown unless active
  end
  def update_falldown
    fallen = @field.falldown
    @phase.change :eliminate
  end
  def update_eliminate
    eliminated = @field.eliminate
    @phase.change eliminated ? :falldown : (@phase.wait(16); :control_block)
  end

  def falldown_eliminate_cond
    # wait fall && land animation
    !@field.blocks_move? && !@field.blocks_land?
  end
  def eliminate_control_block_cond
    # wait collapse animation
    !@field.blocks_reasonable_collapse?
  end
  def eliminate_falldown_cond
    # wait collapse animation
    !@field.blocks_reasonable_collapse?
  end

  def update_blocks
    @field.update_blocks
  end

  def draw_field
    @field.draw_field(@x,@y)
  end

  def input_move_row?; false; end
  def input_rotate?; false; end
  def input_fastfall?; false; end
#  def input_momentfall?; false; end
end
