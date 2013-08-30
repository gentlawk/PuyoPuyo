#==============================================================================#
#                              scene_puyopuyo.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ScenePuyoPuyo < SceneBase
  def start
    @players = []
    @players.push(Player1.new(16,16,6,12,16))
    # test
=begin
    @players.first.instance_eval{ @field.set_table(<<EOF)
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
  end
end
