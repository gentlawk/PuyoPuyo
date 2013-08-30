#==============================================================================#
#                               stable_block.rb                                #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class StableBlock < Block
  def initialize(col, block_s)
    super
    init_animation
  end
  def init_animation
    @move_x = nil
    @move_y = nil
    @move_y_wait = nil
    @collapse = nil
    @land = nil
    @draw_pos = [0,0]
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
  def set_move_y_wait(time)
    @move_y_wait = {
      :counter => time
    }
  end
  def set_land(block, depth, time)
    time_divide = Math::PI / time
    rad = 0
    shifts = []
    time.times do
      rad += time_divide
      shifts.push(-Math.sin(rad) * depth)
    end
    @land = {
      :fallblock => block,
      :shifts => shifts
    }
  end
  def set_dummy_flag block; set_land(block, 0, 2); end

  def update_move_y_wait
    return false unless @move_y_wait
    @move_y_wait[:counter] -= 1
    @move_y_wait = nil if @move_y_wait[:counter] == 0
    return true
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

  def update_land
    return nil unless @land
    return nil if @land[:fallblock].move_y?
    y_shift = @land[:shifts].shift
    @land = nil if @land[:shifts].empty?
    return y_shift
  end

  def update
    # update move_y_wait
    y_wait = update_move_y_wait
    # update move_x move_y
    x = update_move(@move_x){@move_x = nil}
    y = y_wait ? @draw_pos[1] : update_move(@move_y){@move_y = nil}
    @draw_pos[0] = x ? x : @row * @block_s
    @draw_pos[1] = y ? y : @line * @block_s
    # update land
    y_shift = update_land unless move_y?
    @draw_pos[1] += y_shift if y_shift
    # update collapse
    update_collapse
  end

  def move_y_wait?; !@move_y_wait.nil?; end
  def wait?; move_y_wait?; end
  def move_x?; !@move_x.nil?; end
  def move_y?; !@move_y.nil?; end
  def move?; move_x? || move_y?; end
  def collapse?; !@collapse.nil?; end
  def land?; !@land.nil?; end
  def animation?; wait? || move? || collapse? || land?; end
  def reasonable_collapse?
    return false unless @collapse
    @collapse[:counter] >= @collapse[:time] / 5
  end

  def draw(ox,oy)
    if @collapse
      alpha = @collapse[:counter] * 255 / @collapse[:time]
    else
      alpha = 255
    end
    super(ox, oy, alpha)
  end
end
