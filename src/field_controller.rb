#==============================================================================#
#                             field_controller.rb                              #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class FieldController
  def initialize(x,y,row_s, line_s, block_s)
    @x = x; @y = y
    @wait = 0
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
    return if update_wait
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
  def update_wait
    @wait > 0 ? (@wait -=1; true) : false
  end
  
  def start_control_block
    @field.start_control_block(@colors)
  end
  
  def update_control_block
    active = @field.update_control_block
    @phase.change :falldown unless active
  end
  def update_falldown
    fallen = @field.falldown
    @phase.change :eliminate
  end
  def update_eliminate
    eliminated = @field.eliminate
    @phase.change eliminated ? :falldown : :control_block
  end

  def falldown_eliminate_cond
    # wait fall animation
    !@field.blocks_move?
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

  def input_move_right?; false; end
  def input_move_left?; false; end
  def input_rotate_right?; false; end
  def input_rotate_left?; false; end
  def input_fastfall?; false; end
#  def input_momentfall?; false; end
end
