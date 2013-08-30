#==============================================================================#
#                              jammer_manager.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class JammerManager
  attr_accessor :jammers
  attr_reader :gen_jammers

  def initialize(row_s, line_s)
    @row_s = row_s
    @line_s = line_s
    @jammers = 0
    @rest = 0
    @fall_max = (line_s / 3 + 1) * row_s
    @gen_jammers = 0
    init_order
  end

  def init_order
    @order = Array.new(@row_s){|r| r}.shuffle!.rotate_each
  end

  def jammers=(num)
    @jammers = num
    @jammers = 0 if @jammers < 0
  end

  def calc_effective_rate(rate, margin, playtime)
    playsec = playtime / 60
    rate_index = (playsec - margin) / 0x20
    if rate_index < 0 # margin
      effective_rate = rate
    elsif rate_index >= 14 # max rate
      effective_rate = (rate * Rational(2, 256)).to_i
    else
      effective_rate = (rate * Rational(3 - rate_index % 2, 4 * 2 ** (rate_index/2))).to_i
    end
    [effective_rate, 1].max
  end

  def calc_jammer(score, rate, margin, playtime)
    effective_rate = calc_effective_rate(rate, margin, playtime)
    score += @rest # prev calc rest
    @rest = score % effective_rate
    @gen_jammers = score / effective_rate
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
