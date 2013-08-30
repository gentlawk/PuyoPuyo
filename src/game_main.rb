#==============================================================================#
#                                 game_main.rb                                 #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
module GameMain
  @scene = []

  def self.main
    scene_push(ScenePuyoPuyo)
    StarRuby::Game.run(320, 240, :title => "PuyoPuyo", :fps => 60) do |game|
      break if @scene.empty?
      @scene.last.main
    end
  end
  
  def self.game
    StarRuby::Game.current
  end
  def self.screen
    StarRuby::Game.current.screen
  end

  def self.scene_push(scene)
    @scene.push scene.new
    @scene.last.start
  end

  def self.scene_pop
    @scene.pop.terminate
  end

  def self.scene
    @scene.first
  end
end

if __FILE__ == "game_main.rb"
  require "./require.rb"
  GameMain.main
end
