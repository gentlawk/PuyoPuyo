#==============================================================================#
#                            scene_single_player.rb                            #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class SceneSinglePlayer < ScenePuyoPuyo
  def start
    super
    @players.push(Player1.new(16,16,6,12,16))
  end

  def gameover
    GameMain.scene_change SceneSinglePlayer
  end
end
