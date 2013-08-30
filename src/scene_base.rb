#==============================================================================#
#                                scene_base.rb                                 #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class SceneBase
  def initialize
  end

  def start
  end

  def main
    GameMain.game.screen.clear
    Debug.update
    update
  end

  def update
    
  end

  def terminate
  end
end
