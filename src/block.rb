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
    init_animation
  end
  def init_animation
    @move_x = nil
    @move_y = nil
    @collapse = nil
    @draw_pos = [0,0]
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

  def set_move_x(from, to, speed)
    @move_x = {
      :from => from,
      :to => to,
      :speed => speed,
      :counter => 0
    }
  end
  def set_move_y(from, to, speed)
    @move_y = {
      :from => from,
      :to => to,
      :speed => speed,
      :counter => 0
    }
  end
  def set_collapse
    
  end
  
  def update_move(param)
    return nil unless param
    pos = param[:from] + param[:counter] + param[:speed]
    param[:counter] += param[:speed]
    if param[:speed] > 0
      (pos = param[:to]; yield) if pos > param[:to]
    else
      (pos = param[:to]; yield) if pos < param[:to]
    end
    return pos
  end

  def update(block_s)
    x = update_move(@move_x){@move_x = nil}
    y = update_move(@move_y){@move_y = nil}
    @draw_pos[0] = x ? x : @row * block_s
    @draw_pos[1] = y ? y : @line * block_s
  end

  def move_x?; !@move_x.nil?; end
  def move_y?; !@move_y.nil?; end
  def move?; move_x? || move_y?; end
  def animation?; move?; end

  def draw(ox,oy,block_s)
    x = ox + @draw_pos[0]
    y = oy - @draw_pos[1]
    screen = GameMain.screen
    screen.render_rect(x, y, block_s, block_s, get_color)
  end
end
