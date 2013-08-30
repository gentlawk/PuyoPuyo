#==============================================================================#
#                              jammer_manager.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class JammerManager
  attr_accessor :jammers
  attr_reader :gen_jammers
  attr_accessor :rivals_buf

  def initialize(row_s, line_s)
    @row_s = row_s
    @line_s = line_s
    @jammers = 0
    @rest = 0
    @fall_max = (line_s / 3 + 1) * row_s
    @gen_jammers = 0
    @rivals_buf = {}
    @rivals = []
    init_order
  end

  def init_order
    @order = Array.new(@row_s){|r| r}.shuffle!.rotate_each
  end

  def jammers=(num)
    @jammers = num
    @jammers = 0 if @jammers < 0
  end

  def rivals=(rivals)
    @rivals = rivals.map{|rival| rival.field.jm }
    @rivals_buf = {}
    @rivals.each do |rival|
      @rivals_buf[rival] = 0
    end
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

  def total_jammers
    self.jammers + self.total_rivals_buf
  end

  def total_rivals_buf
    @rivals_buf.inject(0){|sum,(rival,num)| sum + num}
  end
  def offset_rivals_buf(num)
    return num if @rivals.empty?
    offset_per = [num / @rivals.size, 1].max
    rest = num
    @rivals.shuffle.each do |rival|
      return 0 if rest == 0
      if rest >= offset_per && @rivals_buf[rival] >= offset_per
        @rivals_buf[rival] -= offset_per
        rest -= offset_per
      elsif @rivals_buf[rival] >= rest
        @rivals_buf[rival] -= rest
        rest = 0
      else
        rest -= @rivals_buf[rival]
        @rivals_buf[rival] = 0
      end
    end
    rest = offset_rivals_buf(num) if rest < num
    rest
  end

  def store_buf(num)
    # offset certain jammers
    rest = num - self.jammers
    self.jammers -= num
    return if rest <= 0
    # offset buffered jammers
    rest = offset_rivals_buf(rest)
    # attack
    @rivals.each do |rival|
      next if rival.rivals_buf[self].nil?
      rival.rivals_buf[self] += rest
    end
  end

  def establish_rival_buf(rival)
    return if @rivals_buf[rival].nil?
    @jammers += @rivals_buf[rival]
    @rivals_buf[rival] = 0
  end

  def establish_jammers
    @rivals.each do |rival|
      rival.establish_rival_buf(self)
    end
  end
end
