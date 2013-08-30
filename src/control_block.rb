#==============================================================================#
#                               control_block.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ControlBlock
  def initialize
    clear
  end
  def clear
    @pivot = nil
    @belongs = []
    @postpone = 0
  end

  def set(pivot, *belongs, postpone)
    @pivot = pivot
    @belongs = belongs
    @postpone = postpone
  end
  
  def start
    if @pivot
      @pivot.row = 2
      @pivot.line = 13
    end
    @belongs.each do |block|
      block.row = 2
      block.line = 14
    end
  end

  def can_falldown?(table)
    lines = blocks.group_by{|block| block.row}.map{|row, blks|
      min_line = blks.min_by{|blk| blk.line}.line
      return false if table[row].size >= min_line
      min_line - table[row].size
    }
    return lines.min # line number ctrl block can falldown
  end

  def falldown(line_num, speed, block_s)
    blocks.each do |block|
      y1 = block.line * block_s
      y2 = (block.line - line_num) *block_s
      block.set_move_y(y1, y2, speed)
      block.line -= line_num
    end
  end

  def update_postpone
    @postpone -= 1
  end

  def blocks
    return [@pivot, *@belongs].compact
  end

  def move_x?
    blocks.each do |block|
      return true if block.move_x?
    end
    return false
  end
  def move_y?
    blocks.each do |block|
      return true if block.move_y?
    end
    return false
  end
  def move?
    blocks.each do |block|
      return true if block.move?
    end
    return false
  end

  def postpone?; @postpone > 0; end
  def active?; !@pivot.nil?; end
end

if __FILE__ == "control_block.rb"
  require "./require.rb"
  ctrl_block = ControlBlock.new
  pivot = Block.new(:r)
  belong = Block.new(:g)
  ctrl_block.set(pivot, belong)
  p ctrl_block.blocks
end
