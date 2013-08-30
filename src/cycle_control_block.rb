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
end
