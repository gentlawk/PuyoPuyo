#==============================================================================#
#                              scene_puyopuyo.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ScenePuyoPuyo < SceneBase
  def start
    @players = []
    @players.push(FieldController.new(16,16))
    # test
    @players.first.instance_eval{ @field.set_table(<<EOF)
......
......
......
......
......
......
..yb.r
.....b
...rgb
...yrg
..yrgb
.ryrgb
EOF
    }
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
