#==============================================================================#
#                              scene_puyopuyo.rb                               #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class ScenePuyoPuyo < SceneBase
  def start
    @players = []
    @players.push(FieldController.new(16,16,6,12,16))
    # test
    @players.first.instance_eval{ @field.set_table(<<EOF)
......
......
......
......
......
......
.....r
.....b
...rgb
..yyrg
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
