#==============================================================================#
#                               control_block.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ControlBlock
  attr_accessor :momentfall
  def initialize
    clear
  end
  def clear
    @postpone = 0
    @momentfall = false
  end

  def set(postpone)
    @postpone = postpone
  end
  
  def start(row, line)
  end

  def can_rotate?(ir, table, row_s)
  end

  def rotate(rotate, table, row_s)
  end

  def rotate?
    blocks.each do |block|
      return true if block.rotate?
    end
    return false
  end

  def can_move_row?(imr, table, row_s)
    return false if imr == 0 # no move
    blocks.group_by{|block| block.line}.each do |line, blks|
      if imr > 0 # move right
        row = blks.max_by{|blk| blk.row}.row
        return false if row >= row_s - 1
        return false if table[row + 1][line]
      else # move left
        row = blks.min_by{|blk| blk.row}.row
        return false if row <= 0
        return false if table[row - 1][line]
      end
    end
    return true
  end

  def move_row(imr, speed, block_s)
    blocks.each do |block|
      x1 = block.row * block_s
      x2 = x1 + imr * block_s
      block.set_move_x(x1, x2, imr * speed)
      block.row += imr
    end
  end
  
  def can_falldown?(table, block_s)
    fall_ys = blocks.group_by{|block| block.row}.map{|row, blks|
      min_y = blks.min_by{|blk| blk.draw_pos[1]}.draw_pos[1]
      # min_y is on table ? fall or dent : dent(line 0)
      min_y >= 0 ? min_y - table[row].size * block_s : min_y
    }
    # fall_ys == 0 : can not fall
    #         >  0 : fall y
    #         <  0 : dent y
    return fall_ys.min
  end

  def falldown(y)
    blocks.each do |block|
      block.draw_pos[1] -= y
    end
  end

  def fix_dent(y)
    blocks.each do |block|
      block.draw_pos[1] += y
    end
  end

  def update_postpone
    @postpone -= 1
  end

  def blocks
    return []
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
