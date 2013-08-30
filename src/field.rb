#==============================================================================#
#                                   field.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Field
  attr_reader :table

  def initialize(row_s, line_s, block_s = 16)
    @row_s = row_s
    @line_s = line_s
    @block_s = block_s
    @fallen = false
    @eliminated = false
    init_table
    init_blocklist
    init_connect_table
  end
  def init_table
    @table = Array.new(@row_s){ [] }
    def @table.dup
      _dup = []
      self.each do |row|
        _dup.push row.dup
      end
      _dup
    end
  end
  def init_blocklist
    @blocklist = []
  end
  def init_connect_table
    @connect_table = []
    @checklist = []
  end
  def set(r,l,col)
    if @table[r][l]
      @blocklist.delete @table[r][l]
    end
    block = Block.new(col)
    block.row = r
    block.line = l
    @table[r][l] = block
    @blocklist.push block
  end
  
  def falldown_line(r)
    return unless @table[r].compact!
    @fallen = true
    @table[r].each.with_index do |block, l|
      block.line = l
    end
  end

  def falldown
    @fallen = false
    @row_s.times do |r|
      falldown_line(r)
    end
    @fallen
  end

  def check_connection(r,l,col)
    return if r < 0 || r >= @row_s
    return if l < 0 || l >= @line_s
    return unless @table[r][l]
    block = @table[r][l]
    return unless @checklist.include? block
    return unless @table[r][l] && @table[r][l].color == col
    @checklist.delete block
    @connect_table[-1].push block
    check_connection(r,l+1,col) # up
    check_connection(r,l-1,col) # down
    check_connection(r+1,l,col) # right
    check_connection(r-1,l,col) # left
  end

  def make_connect_table
    init_connect_table
    @checklist = @blocklist.dup
    while !@checklist.empty?
      block = @checklist.first
      r = block.row; l = block.line
      col = block.color
      @connect_table.push []
      check_connection(r,l,col)
    end
  end

  def eliminate_connection
    @connect_table.each do |connection|
      next if connection.size < 4
      @eliminated = true # check flag
      connection.each do |block|
        @table[block.row][block.line] = nil
        @blocklist.delete block
      end
    end
  end

  def eliminate
    @eliminated = false
    make_connect_table
    eliminate_connection
    @eliminated
  end

  def set_table(tstr)
    init_table
    tstr.split("\n").each.with_index do |line, l|
      l = @line_s - (l + 1)
      line.split("").each.with_index do |col,r|
        next if col == "."
        set(r,l,col.to_sym)
      end
    end
  end

  def print_field
    # header
    puts "-" * (@row_s + 2)
    # field
    dup_t = @table.dup
    dup_t.each do |row|
      row.concat Array.new(@line_s - row.size, nil)
    end
    f_trans = dup_t.transpose.reverse
    f_trans.each do |line|
      print "|"
      line.each do |block|
        print(block ? block.color.to_s : " ")
      end
      puts "|"
    end
    # footer
    puts "-" * (@row_s + 2)
  end

  def draw_field(x,y)
    y = @line_s * @block_s + y
    @blocklist.each do |block|
      block.draw(x,y,@block_s)
    end
  end
end

if __FILE__ == "field.rb"
  require "./require"
  field = Field.new(6,12)
  tstr =<<EOF
......
b.....
y.....
b.....
b.r...
r.b...
r....y
bbb.yg
rygrbg
rbygrb
bygrbg
bygrbg
EOF
  field.set_table(tstr)
  field.print_field
  loop do
    fallen = field.falldown
    field.print_field if fallen
    eliminated = field.eliminate
    field.print_field if eliminated
    break if !fallen && !eliminated
  end
end
