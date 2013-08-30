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
  end

  def main
    super
  end

  def gameover
    GameMain.scene_change ScenePuyoPuyo
  end

  def update
    super
    all_dead = true
    @players.each do |controller|
      controller.update
      all_dead = false unless controller.dead?
    end
    @playtime += 1
    gameover if all_dead
  end
end
