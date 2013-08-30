#==============================================================================#
#                                   block.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Block
  attr_accessor :color, :row, :line
  def initialize(col)
    @color = col
    @row = -1
    @line = -1
  end

  def inspect
    sprintf("|(%2d,%2d):%s|",@row,@line,@color.to_s)
  end

  def to_s
    sprintf("|(%2d,%2d):%s|",@row,@line,@color.to_s)
  end

  def get_color
    case @color
    when :r
      StarRuby::Color.new(255,128,128)
    when :g
      StarRuby::Color.new(128,255,128)
    when :b
      StarRuby::Color.new(128,128,255)
    when :y
      StarRuby::Color.new(255,255,128)
    when :p
      StarRuby::Color.new(255,128,255)
    end
  end

  def draw(ox,oy,size)
    x = ox + @row * size
    y = oy - @line * size
    screen = GameMain.screen
    screen.render_rect(x, y, size, size, get_color)
  end
end
