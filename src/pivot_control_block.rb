#==============================================================================#
#                            pivot_control_block.rb                            #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
=begin
pivot = p
belongs = [b0, b1, b2, b3]
   b0
b3 p  b1
   b2
-----------------
form:
 b0           b0
 p      OR    p  b1
=end
class PivotControlBlock < ControlBlock
  def clear
    super
    @pivot = nil
    @belongs = []
  end

  def set(pivot, *belongs, postpone)
    super(postpone)
    @pivot = pivot
    @belongs = Array.new(4){|i| belongs[i] }
  end
  
  def start(row, line)
    if @pivot
      @pivot.row = row
      @pivot.line = line
    end
    @belongs.each.with_index do |block, i|
      next unless block
      case i
      when 0; row_shift = 0 ; line_shift = 1
      when 1; row_shift = 1 ; line_shift = 0
      when 2; row_shift = 0 ; line_shift = -1
      when 3; row_shift = -1; line_shift = 0
      end
      block.row = row + row_shift
      block.line = line + line_shift
    end
  end
  
  def blocks
    return [@pivot, *@belongs].compact
  end

  def can_rotate?(ir, table, row_s)
    return false if ir == 0 # no rotate
    r = @pivot.row; l = @pivot.line
    max_cond = r < row_s - 1
    min_cond = r > 0
    @belongs.each.with_index do |block,i|
      next if !block || i % 2 != 0
      row_dir = ir * (1 - i)
      if (row_dir > 0 ? max_cond : min_cond) && !table[r+row_dir][l] # OK
        return {:dir => ir, :shift => 0}
      elsif (row_dir > 0 ? min_cond : max_cond) && !table[r-row_dir][l] # OK: shift
        return {:dir => ir, :shift => -row_dir}
      end
      # NG
      return false
    end
    return {:dir => ir, :shift => 0}
  end

  def rotate?
    blocks.each do |block|
      return true if block.rotate?
    end
    return false
  end
  
  def rotate(rotate, time)
    # pivot
    @pivot.row += rotate[:shift]
    @pivot.set_rotate(0, 0, time, rotate[:shift]) if rotate[:shift] != 0
    # belongs
    @belongs.rotate!(-rotate[:dir])
    @belongs.each.with_index do |block, i|
      next unless block
      # set animation
      to = 90 * (1 - i)
      block.set_rotate(to + 90 * rotate[:dir], to, time, rotate[:shift])
      case i
      when 0; block.row += rotate[:dir]
      when 1; block.row += 1
      when 2; block.row += -rotate[:dir]
      when 3; block.row += -1
      end
      # shift
      block.row += rotate[:shift]
    end
  end
end

if __FILE__ == "control_block.rb"
  require "./require.rb"
  ctrl_block = PivotControlBlock.new
  pivot = Block.new(:r)
  belong = Block.new(:g)
  ctrl_block.set(pivot, belong)
  p ctrl_block.blocks
end
