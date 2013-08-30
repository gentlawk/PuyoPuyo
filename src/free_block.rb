#==============================================================================#
#                                free_block.rb                                 #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
# row : base on @row [ draw_pos < row ]
# line : base on @draw_pos[1] [ draw_pos > line ]
class FreeBlock < Block
  def initialize(col, block_s)
    super
    init_animation
  end

  def init_animation
    @move_x = nil
    @rotate_x = nil
    @rotate_y = nil
  end

  def line=(line)
    @draw_pos[1] = line * @block_s
    @line = line
  end

  def set_move_x(from, to, speed)
    @move_x = {
      :from => from,
      :to => to,
      :speed => speed,
      :counter => 0
    }
  end

  def set_rotate_x(from, to, time, push_shift)
    # x : rotate distance list based on to
    from_rad = from * Math::PI / 180
    to_rad = to * Math::PI / 180
    time_divide = (to_rad - from_rad) / time
    shift = Math.cos(to_rad) * @block_s
    ps_divide = (push_shift * @block_s).quo time
    rotate = []
    rad = from_rad
    ps = push_shift * @block_s
    time.times do
      rad += time_divide
      ps -= ps_divide
      rotate.push(Math.cos(rad) * @block_s - shift - ps)
    end
    return rotate
  end

  def set_rotate_y(from, to, time)
    # y : rotate speed list base on from
    from_rad = from * Math::PI / 180
    to_rad = to * Math::PI / 180
    time_divide = (to_rad - from_rad) / time
    rotate = []
    rad = from_rad
    time.times do
      old = rad
      rad += time_divide
      rotate.push((Math.sin(rad) - Math.sin(old)) * @block_s)
    end
    return rotate
  end

  def set_rotate(from, to, time, shift)
    @rotate_x = set_rotate_x(from, to, time, shift)
    @rotate_y = set_rotate_y(from, to, time)
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

  def update_rotate(rotate)
    return nil unless rotate
    x_shift =  rotate.shift
    yield if rotate.empty?
    return x_shift
  end

  def update
    # update move_x
    x = update_move(@move_x){@move_x = nil}
    @draw_pos[0] = x ? x : @row * @block_s
    # update rotate
    x_shift = update_rotate(@rotate_x){@rotate_x = nil}
    y_shift = update_rotate(@rotate_y){@rotate_y = nil}
    @draw_pos[0] += x_shift if x_shift
    @draw_pos[1] += y_shift if y_shift
    # update line
    @line = (@draw_pos[1].round + @block_s / 2) / @block_s
  end

  def move_x?; !@move_x.nil?; end
  def move?; move_x?; end
  def rotate?; !(@rotate_x.nil? && @rotate_y.nil?); end
  def animation?; move? || rotate?; end

  def convert_stable
    sb = StableBlock.new(@color, @block_s)
    sb.row = @row
    sb.line = @line
    sb
  end
end
