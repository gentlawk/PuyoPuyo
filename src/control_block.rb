#==============================================================================#
#                               control_block.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ControlBlock
  def initialize
    init_blocks
  end
  def init_blocks
    @pivot = nil
    @belongs = []
  end

  def set(pivot, *belongs)
    @pivot = pivot
    @belongs = belongs
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
    blocks.group_by{|block| block.row}.each do |row, blks|
      min_line = blks.min_by{|blk| blk.line}.line
      return false if table[row].size >= min_line
    end
    return true
  end

  def falldown(speed, block_s)
    blocks.each do |block|
      y = block.line * block_s
      block.set_move_y(y, y - block_s, speed)
      block.line -= 1
    end
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
end

if __FILE__ == "control_block.rb"
  require "./require.rb"
  ctrl_block = ControlBlock.new
  pivot = Block.new(:r)
  belong = Block.new(:g)
  ctrl_block.set(pivot, belong)
  p ctrl_block.blocks
end
