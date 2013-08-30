#==============================================================================#
#                                   block.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Block
  attr_accessor :color, :row, :line
  attr_reader :draw_pos
  def initialize(col, block_s)
    @color = col
    @row = -1
    @line = -1
    @block_s = block_s
    @draw_pos = [0,0]
  end

  def inspect
    sprintf("|(%2d,%2d):%s|",@row,@line,@color.to_s)
  end

  def to_s
    sprintf("|(%2d,%2d):%s|",@row,@line,@color.to_s)
  end

  def get_color(alpha = 255)
    case @color
    when :r
      StarRuby::Color.new(255,128,128,alpha)
    when :g
      StarRuby::Color.new(128,255,128,alpha)
    when :b
      StarRuby::Color.new(128,128,255,alpha)
    when :y
      StarRuby::Color.new(255,255,128,alpha)
    when :p
      StarRuby::Color.new(255,128,255,alpha)
    when :j
      StarRuby::Color.new(200,200,200,200*alpha/255)
    end
  end

  def update
    @draw_pos[0] = @row * @block_s
    @draw_pos[1] = @line * @block_s
  end

  def draw(ox,oy,alpha=255)
    x = ox + @draw_pos[0].round
    y = oy - @draw_pos[1].round
    screen = GameMain.screen
    screen.render_rect(x, y, @block_s, @block_s, get_color(alpha))
  end
end
