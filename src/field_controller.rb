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
    init_field
    init_phase
  end
  def init_field
    @field = Field.new(@@row_s, @@line_s)
  end
  def init_phase
    @phase = :falldown
    @wait = 0
  end
  def update
    update_blocks
    draw_field
    return if update_wait
    case @phase
    when :falldown
      update_falldown
    when :eliminate
      update_eliminate
    end
  end
  def update_wait
    @wait > 0 ? (@wait -=1; true) : false
  end
  def update_falldown
    # wait collapse animation
    return if @field.blocks_reasonable_collapse?

    fallen = @field.falldown
    @phase = :eliminate
  end
  def update_eliminate
    # wait fall animation
    return if @field.blocks_move?

    eliminated = @field.eliminate
    @phase = :falldown
  end
  def update_blocks
    @field.update_blocks
  end

  def draw_field
    @field.draw_field(@x,@y)
  end
end
