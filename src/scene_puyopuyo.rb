#==============================================================================#
#                              scene_puyopuyo.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ScenePuyoPuyo < SceneBase
  attr_reader :playtime
  attr_reader :margin_time

  def start
    @playtime = 0
    @margin_time = 96

    @players = []
    @players.push(Player1.new(16,16,6,12,16))
    # test
=begin
    @players.first.instance_eval{ ctbl = @field.get_color_table(<<EOF)
......
......
......
....y.
..r.y.
..g.y.
..g.rg
..grrg
..byyy
..yrrg
..yrgg
.rybbb
EOF
      @field.set_table(ctbl)
    }
=end
  end

  def main
    super
  end

  def update
    super
    @players.each do |controller|
      controller.update
    end

    @playtime += 1
  end
end
