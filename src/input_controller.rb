#==============================================================================#
#                             input_controller.rb                              #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class InputController
  @@repeat_delay = 6
  @@repeat_interval = 1
  @@keys = [:up, :down, :right, :left, :button1, :button2]
  @@keymap = []
  @@keymap[1] = { # Player1 keymap
    :up => :w,
    :down => :s,
    :right => :d,
    :left => :a,
    :button1 => :f,
    :button2 => :g
  }
  @@keymap[2] = { # Player2 keymap
    :up => :up,
    :down => :down,
    :right => :right,
    :left => :left,
    :button1 => :numpad2,
    :button2 => :numpad3
  }

  def initialize(player)
    @player = player
    @press_count = {}
    @@keys.each do |key|
      @press_count[key] = 0
    end
  end

  def update
    input_keys = StarRuby::Input.keys(:keyboard)
    @@keys.each do |key|
      if input_keys.include? @@keymap[@player][key]
        @press_count[key] += 1
      else
        @press_count[key] = 0
      end
    end
  end

  def press?(key); @press_count[key] > 0; end
  def trigger?(key); @press_count[key] == 1; end
  def repeat?(key)
    count = @press_count[key]
    return false if count == 0
    return true if count == 1
    return false if count <= @@repeat_delay + 2
    return (count - @@repeat_delay - 2) % @@repeat_interval == 0
  end
end

if __FILE__ == "input_controller.rb"
  require "./require"
  ipt_ctrl = InputController.new(1)
  StarRuby::Game.run(200,64,title: "InputController") do |game|
    game.screen.clear
    ipt_ctrl.update
    [:up,:down,:right,:left,:button1,:button2].each.with_index do |key,i|
      y = i * 8 + 8
      c = StarRuby::Color.new(i*30+50,i*30+50,i*30+50)
      game.screen.render_line(0,y,200,y,c) if ipt_ctrl.press?(key)
      game.screen.render_line(0,y+4,200,y+4,c) if ipt_ctrl.trigger?(key)
    end
  end
end
