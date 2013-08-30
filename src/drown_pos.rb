#==============================================================================#
#                                 drown_pos.rb                                 #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class DrownPos
  def initialize(m, n, block_s)
    @row = m; @line = n
    @block_s = block_s
  end

  def draw(ox,oy)
    x = ox + @row * @block_s
    y = oy - @line * @block_s
    screen = GameMain.screen
    screen.render_rect(x, y, @block_s, @block_s, StarRuby::Color.new(255,0,0,180))
  end

  def to_a
    [@row, @line]
  end
end
