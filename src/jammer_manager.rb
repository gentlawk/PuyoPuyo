#==============================================================================#
#                              jammer_manager.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class JammerManager
  attr_accessor :jammers
  def initialize(row_s, line_s)
    @row_s = row_s
    @line_s = line_s
    @jammers = 0
    @fall_max = (line_s / 3 + 1) * row_s
    init_order
  end

  def init_order
    @order = Array.new(@row_s){|r| r}.shuffle!.each
    def @order.next # loop next
      super rescue self.rewind.next
    end
  end

  def jammers=(num)
    @jammers = num
    @jammers = 0 if @jammers < 0
  end

  def get_fall_table
    fall_num = @jammers > @fall_max ? @fall_max : @jammers
    @jammers -= fall_num
    # make table
    table = Array.new(@row_s){ [] }
    @row_s.times do
      break if fall_num == 0 
      row = @order.next
      fall_num -= 1
      num = 1 + fall_num / @row_s
      table[row] = Array.new(num, :j)
    end
    return table
  end
end
