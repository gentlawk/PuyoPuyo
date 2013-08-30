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

  def update
    # update move_x
    x = update_move(@move_x){@move_x = nil}
    @draw_pos[0] = x ? x : @row * @block_s
    # update line
    @line = (@draw_pos[1].truncate + @block_s / 2) / @block_s
  end

  def move_x?; !@move_x.nil?; end
  def move?; move_x?; end
  def animation?; move?; end

  def convert_stable
    sb = StableBlock.new(@color, @block_s)
    sb.row = @row
    sb.line = @line
    sb
  end
end
