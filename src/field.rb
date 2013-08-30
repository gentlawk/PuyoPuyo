#==============================================================================#
#                                   field.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Field
  attr_reader :table

  def initialize(row_s, line_s, block_s)
    @row_s = row_s
    @line_s = line_s
    @block_s = block_s
    @fallen = false
    @eliminated = false
    init_control_block_manager
    init_table
    init_blocklist
    init_connect_table
  end
  def init_control_block_manager
    @cbm = ControlBlockManager.new
    @cbm.set_type(PivotControlBlock)
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
    @active_blocks = []
    @collapse_blocks = []
  end
  def init_connect_table
    @connect_table = []
    @checklist = []
  end
  def set(r,l,col)
    if @table[r][l]
      @active_blocks.delete @table[r][l]
    end
    block = StableBlock.new(col, @block_s)
    block.row = r
    block.line = l
    @table[r][l] = block
    @active_blocks.push block
  end
  
  def update_blocks
    (@active_blocks + @collapse_blocks + @cbm.ctrl_block.blocks).each do |block|
      block.update
    end
    @collapse_blocks.delete_if{|block| !block.collapse? }
  end

  def start_control_block(colors)
    @cbm.ctrl_block.clear
    pivot = FreeBlock.new(colors.sample, @block_s)
    belong = FreeBlock.new(colors.sample, @block_s)
    @cbm.ctrl_block.set(pivot, belong, 40)
    @cbm.ctrl_block.start(2,12)
  end

  def update_control_block(imr,ir,iff)
    update_control_block_rotate(ir)
    update_control_block_move_x(imr)
    active = update_control_block_move_y(iff)
  end

  def update_control_block_rotate(ir)
    return true if @cbm.ctrl_block.rotate?
    rotate = @cbm.ctrl_block.can_rotate?(ir, @table, @row_s)
    return false unless rotate
    @cbm.ctrl_block.rotate(rotate, 8)
  end

  def update_control_block_move_x(imr)
    return true if @cbm.ctrl_block.move_x?
    return false unless @cbm.ctrl_block.can_move_row?(imr,@table,@row_s)
    @cbm.ctrl_block.move_row(imr, 6, @block_s)
    return true
  end

  def update_control_block_move_y(iff)
    fall_y = @cbm.ctrl_block.can_falldown?(@table, @block_s)
    if fall_y > 0 # fall
      speed = iff ? 6 : 0.8
      @cbm.ctrl_block.falldown(fall_y > speed ? speed : fall_y)
    elsif fall_y < 0 # dent
      @cbm.ctrl_block.fix_dent(-fall_y)
    else # postpone or land
      if !iff && @cbm.ctrl_block.postpone?
        @cbm.ctrl_block.update_postpone
      else
        control_block_land
        return false
      end
    end
    return true
  end

  def control_block_land
    stable_blocks = @cbm.ctrl_block.blocks.map{|block| block.convert_stable}
    @active_blocks.concat stable_blocks
    stable_blocks.each do |block|
      @table[block.row][block.line] = block
    end
    @cbm.ctrl_block.clear
  end

  def falldown_line(r)
    return unless @table[r].compact!
    @fallen = true
    @table[r].each.with_index do |block, l|
      next if block.line == l
      block.set_move_y(block.line * @block_s, l * @block_s, -6)
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
    @checklist = @active_blocks.dup
    while !@checklist.empty?
      block = @checklist.first
      r = block.row; l = block.line
      # not consider if block out of screen
      if r < 0 || r >= @row_s || l < 0 || l >= @line_s
        @checklist.shift
        next
      end
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
        block.set_collapse(40)
        @table[block.row][block.line] = nil
        @active_blocks.delete block
        @collapse_blocks.push block
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

  def blocks_move_x?
    @active_blocks.each do |block|
      return true if block.move_x?
    end
    return false
  end
  def blocks_move_y?
    @active_blocks.each do |block|
      return true if block.move_y?
    end
    return false
  end
  def blocks_move?
    @active_blocks.each do |block|
      return true if block.move?
    end
    return false
  end
  def blocks_collapse?
    @collapse_blocks.each do |block|
      return true if block.collapse?
    end
    return false
  end
  def blocks_reasonable_collapse?
    @collapse_blocks.each do |block|
      return true if block.reasonable_collapse?
    end
    return false
  end
  def blocks_animation?
    @active_blocks.each do |block|
      return true if block.animation?
    end
    @collapse_blocks.each do |block|
      return true if block.collapse?
    end
    return false
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
    (@active_blocks + @collapse_blocks + @cbm.ctrl_block.blocks).each do |block|
      block.draw(x,y)
    end
  end
end

if __FILE__ == "field.rb"
  require "./require"
  field = Field.new(6,12,16)
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
