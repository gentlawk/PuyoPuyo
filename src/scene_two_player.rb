#==============================================================================#
#                             scene_two_player.rb                              #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class SceneTwoPlayer < ScenePuyoPuyo
  def start
    super
    player1 = Player1.new(32,16,6,12,16)
    player2 = Player2.new(32 + 16 *6 + 48,16,6,12,16)
    player1.rivals = [player2]
    player2.rivals = [player1]
    @players.push(player1)
    @players.push(player2)
=begin
    @players[0].instance_eval{ tstr = <<EOF
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
      @field.set_table(@field.get_color_table(tstr))
    }
    @players[1].instance_eval{ tstr = <<EOF
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
      @field.set_table(@field.get_color_table(tstr))
    }
=end
  end

  def gameover
    GameMain.scene_change SceneTwoPlayer
  end
end
