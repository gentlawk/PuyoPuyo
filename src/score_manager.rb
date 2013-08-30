#==============================================================================#
#                               score_manager.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ScoreManager
  attr_accessor :score
  attr_reader :base_score, :chain_bonus, :amount_bonus, :color_bonus
  def initialize
    @score = 0
    clear_chain_score
  end

  def clear_chain_score
    @base_score = 0
    @chain_bonus = 0
    @amount_bonus = 0
    @color_bonus = 0
  end

  def chain_bonus_table(c)
    if c <= 3
      (c - 1) * 8
    elsif c < 35
      (c - 3) * 32
    else
      999
    end
  end

  def amount_bonus_table(n)
    if n < 5
      0
    elsif n > 10
      10
    else
      n - 3
    end
  end

  def color_bonus_table(c)
    c < 2 ? 0 : 3 * 2 ** (c - 2)
  end

  def calc_chain_score(connect_table, chain)
    return 0 if chain == 0 || connect_table.empty?
    clear_chain_score
    elimination = 0
    jammers = []
    colors = []
    connect_table.each do |connection|
      size = connection[:blocks].size
      @amount_bonus += amount_bonus_table(size)
      elimination += size
      jammers.concat connection[:jammers]
      colors.push  connection[:blocks].first.color
    end
    @base_score = (elimination + jammers.uniq.size) * 10
    @color_bonus = color_bonus_table(colors.uniq.size)
    @chain_bonus = chain_bonus_table(chain)
    
    chain_score
  end

  def mag_bonus
    [[@chain_bonus + @amount_bonus + @color_bonus, 1].max, 999].min
  end

  def chain_score
    @base_score * self.mag_bonus
  end

  def debug_sprintf
    sprintf("%d [%d = %d * (%d + %d + %d)]",
            @score, chain_score, @base_score, @chain_bonus, @amount_bonus, @color_bonus)
  end
end
