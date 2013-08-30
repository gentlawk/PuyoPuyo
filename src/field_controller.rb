#==============================================================================#
#                             field_controller.rb                              #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class FieldController
  @@row_s = 6
  @@line_s = 12
  def initialize(x,y)
    @x = x; @y = y
    @wait = 0
    init_field
    init_phase
  end
  def init_field
    @field = Field.new(@@row_s, @@line_s)
  end
  def init_phase
    @phase = Phase.new
    # added :falldown handler
    @phase.add_condition_handler(:falldown,
                                :eliminate,
                                method(:falldown_eliminate_cond))
    # added :elimiate handler
    @phase.add_condition_handler(:eliminate,
                                 :falldown,
                                 method(:eliminate_falldown_cond))
    @phase.change :falldown
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
  def update_control_block
    # wait collapse animation
    return if @field.blocks_reasonable_collapse?
  end
  def eliminate_falldown_cond
    # wait collapse animation
    !@field.blocks_reasonable_collapse?
  end
  def update_falldown
    fallen = @field.falldown
    @phase.change :eliminate
  end
  def falldown_eliminate_cond
    # wait fall animation
    !@field.blocks_move?
  end
  def update_eliminate
    eliminated = @field.eliminate
    @phase.change :falldown
  end
  def update_blocks
    @field.update_blocks
  end

  def draw_field
    @field.draw_field(@x,@y)
  end
end
