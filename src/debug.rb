#==============================================================================#
#                                   debug.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
module Debug
  @line = 0
  @pos = 0
  @font = StarRuby::Font.new("MS Gothic",12)
  @color = StarRuby::Color.new(255,255,255)
  def self.print(*obj)
    str = obj.to_s
    w,h = @font.get_size(str)
    if @pos + w + 20 > GameMain.screen.width
      @line += 1; @pos = 0
    end
    GameMain.screen.render_text(str, @pos, @line * h, @font, @color)
    @pos += w + 20
  end

  def self.update
    @pos = 0; @line = 0
  end
end
