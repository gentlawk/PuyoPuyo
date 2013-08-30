#==============================================================================#
#                                   block.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#

class Block
  attr_accessor :color, :row, :line
  attr_reader :draw_pos
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
  def set_collapse(time)
    @collapse = {
      :time => time,
      :counter => time
    }
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

  def update_collapse
    return unless @collapse
    if @collapse[:counter] == 0
      @collapse = nil
    else
      @collapse[:counter] -= 1
    end
  end

  def update(block_s)
    # update move_x move_y
    x = update_move(@move_x){@move_x = nil}
    y = update_move(@move_y){@move_y = nil}
    @draw_pos[0] = x ? x : @row * block_s
    @draw_pos[1] = y ? y : @line * block_s
    # update collapse
    update_collapse
  end

  def move_x?; !@move_x.nil?; end
  def move_y?; !@move_y.nil?; end
  def move?; move_x? || move_y?; end
  def collapse?; !@collapse.nil?; end
  def animation?; move? || collapse?; end
  def reasonable_collapse?
    return false unless @collapse
    @collapse[:counter] >= @collapse[:time] / 5
  end

  def draw(ox,oy,block_s)
    x = ox + @draw_pos[0]
    y = oy - @draw_pos[1]
    if @collapse
      alpha = @collapse[:counter] * 255 / @collapse[:time]
    else
      alpha = 255
    end
    screen = GameMain.screen
    screen.render_rect(x, y, block_s, block_s, get_color(alpha))
  end
end
