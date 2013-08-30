#==============================================================================#
#                            cycle_control_block.rb                            #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
=begin
blocks = [b0,b1,b2,b3]
  b1  b2
 (b0) b3
(block) is base block
=end
class CycleControlBlock < ControlBlock
  def clear
    super
    @blocks = []
  end

  def set(*blocks, postpone)
    super(postpone)
    @blocks = Array.new(4){|i| blocks[i] }
  end
  
  def start(row, line)
    @blocks.each.with_index do |block, i|
      next unless block
      case i
      when 0; row_shift = 0; line_shift = 0
      when 1; row_shift = 0; line_shift = 1
      when 2; row_shift = 1; line_shift = 1
      when 3; row_shift = 1; line_shift = 0
      end
      block.row = row + row_shift
      block.line = line + line_shift
    end
  end
  
  def blocks
    return @blocks.compact
  end

  def can_rotate?(ir, table, row_s)
    return ir == 0 ? false : ir
  end

  def rotate(ir, time)
    @blocks.rotate!(-ir)
    @blocks.each.with_index do |block, i|
      next unless block
      case i
      when 0; shift = ir > 0 ? [-1, 0] : [ 0,-1]
      when 1; shift = ir > 0 ? [ 0, 1] : [-1, 0]
      when 2; shift = ir > 0 ? [ 1, 0] : [ 0, 1]
      when 3; shift = ir > 0 ? [ 0,-1] : [ 1, 0]
      end
      block.set_rotate(0, 0, time, *shift)
      block.row += shift[0]
    end
  end

  def can_move_row?(imr, table, row_s)
    return false if imr == 0 # no move
    min_line = [@blocks[0], @blocks[3]].min_by{|block|
      block.draw_pos[1]
    }.line
    row_left = @blocks[0].row; row_right = @blocks[3].row
    [min_line, min_line + 1].each do |line|
      if imr > 0 # move right
        return false if row_right >= row_s - 1
        return false if table[row_right + 1][line]
      else # move left
        return false if row_left <= 0
        return false if table[row_left - 1][line]
      end
    end
    return true
  end

  def can_falldown?(table, block_s)
    min_y = [@blocks[0], @blocks[3]].min_by{|block|
      block.draw_pos[1]
    }.draw_pos[1]
    row_down = @blocks[0].row
    fall_ys = [row_down, row_down + 1].map{|row|
      min_y >= 0 ? min_y - table[row].size * block_s : min_y
    }
    # fall_ys == 0 : can not fall
    #         >  0 : fall y
    #         <  0 : dent y
    return fall_ys.min
  end
end
