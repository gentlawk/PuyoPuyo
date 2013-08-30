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
    fallen = @field.falldown
    @wait = 60 if fallen
    @phase = :eliminate
  end
  def update_eliminate
    eliminated = @field.eliminate
    @wait = 60 if eliminated
    @phase = :falldown
  end

  def draw_field
    @field.draw_field(@x,@y)
  end
end
