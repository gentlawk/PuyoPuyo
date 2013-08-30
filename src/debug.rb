#==============================================================================#
#                                   debug.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
module Debug
  @line = 0
  @pos = 0
  @fonts = {:win => "MS Gothic", :linux => "VL Gothic", :mac => "Hiragino"}
  @color = StarRuby::Color.new(255,255,255)
  os = RUBY_PLATFORM.downcase
  if os =~ /mswin|mingw|cygwin|bccwin/ # windows
    @font = StarRuby::Font.new("MS Gothic",12)
  elsif os =~ /darwin/ # mac
    @font = StarRuby::Font.new("Hiragino",12)
  elsif os =~ /linux/ # linux
    @font = StarRuby::Font.new("VL Gothic",12)
  else # ???
    @font = StarRuby::Font.new("VL Gothic",12)
  end

  def self.print(*objs)
    objs.each do |obj|
      str = obj.to_s
      w,h = @font.get_size(str)
      if @pos + w + 10 > GameMain.screen.width
        @line += 1; @pos = 0
      end
      GameMain.screen.render_text(str, @pos, @line * h, @font, @color)
      @pos += w + 10
    end
  end

  def self.update
    @pos = 0; @line = 0
  end
end
