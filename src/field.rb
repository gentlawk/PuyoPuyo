#==============================================================================#
#                                   field.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Field
  attr_reader :table
  attr_reader :chain

  def initialize(row_s, line_s, block_s, cbm, sm)
    @row_s = row_s
    @line_s = line_s
    @block_s = block_s
    @fallen = false
    @eliminated = false
    @cbm = cbm
    @sm = sm
    @chain = 0
    @jammer_rate = 70
    init_table
    init_jammer_manager
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

  def init_jammer_manager
    @jm = JammerManager.new(@row_s, @line_s)
  end
  def init_blocklist
    @active_blocks = []
    @jamming_blocks = []
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
  
  def all_blocks
    @active_blocks + @jamming_blocks + @collapse_blocks + @cbm.ctrl_block.blocks
  end

  def update_blocks
    all_blocks.each do |block|
      block.update
    end
    @collapse_blocks.delete_if{|block| !block.collapse? }
  end

  def start_control_block(*colors)
    blocks = colors.map{ |color|
      FreeBlock.new(color, @block_s)
    }
    @cbm.ctrl_block.set(*blocks, 40)
    @cbm.ctrl_block.start((@row_s - 1) / 2, @line_s)
  end

  def update_control_block(imr,ir,iff,imf)
    update_control_block_rotate(ir)
    update_control_block_move_x(imr)
    active = update_control_block_move_y(iff,imf)
  end

  def update_control_block_rotate(ir)
    return true if @cbm.ctrl_block.rotate?
    return false if @cbm.ctrl_block.momentfall
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

  def update_control_block_move_y(iff,imf)
    fall_y = @cbm.ctrl_block.can_falldown?(@table, @block_s)
    if fall_y > 0 # fall
      # add score
      @sm.score += 1 if iff && !imf && !@cbm.ctrl_block.momentfall

      speed = iff ? 6 : 0.8
      speed = imf || @cbm.ctrl_block.momentfall ? 64 : speed
      @cbm.ctrl_block.momentfall = true if imf
      @cbm.ctrl_block.falldown(fall_y > speed ? speed : fall_y)
    elsif fall_y < 0 # dent
      @cbm.ctrl_block.fix_dent(-fall_y)
    else # postpone or land
      if !iff && @cbm.ctrl_block.postpone? && !@cbm.ctrl_block.momentfall
        @cbm.ctrl_block.update_postpone
      elsif !@cbm.ctrl_block.rotate?
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
      block.set_dummy_flag(block) # set dummy fall flag
    end
    @cbm.ctrl_block.clear
  end

  def falldown_line(r,speed,waiting)
    @fallen = @table[r].compact! ? true : false
    stable,fall = @table[r].partition.with_index{|block, l|
      block.line == l && !block.land? # dummy flag
    }
    return if fall.empty?
    # fall list animation
    impact = @block_s
    impact_d = impact / 3
    wait = 0
    base = stable.size
    fall.each.with_index do |block, i|
      l = base + i
      imp = l < 2 ? l * impact_d : impact
      block.set_land(block, imp, 16)
      if block.line != l
        block.set_move_y_wait(wait) if wait != 0
        block.set_move_y(block.line * @block_s, l * @block_s, speed)
        block.line = l
        wait += 3 if waiting
      end
    end
    # stable list animation
    fallen_block = fall.first
    _impact = impact
    stable.reverse.each.with_index do |block, i|
      break if _impact <= 0
      l = base - (i + 1)
      _impact = l * impact_d if _impact > l * impact_d
      block.set_land(fallen_block, _impact, 16)
      _impact /= 2
    end
  end

  def falldown(speed = -6, waiting = true)
    @fallen = false
    @row_s.times do |r|
      falldown_line(r,speed,waiting)
    end
    @fallen
  end

  def check_con_jammer(r,l,col,block)
    #return false unless @jamming_blocks.include? block # should be included
    @connect_table[-1][:jammers].push block
    return false
  end

  def check_con_block(r,l,col,block)
    return false unless @checklist.include? block
    return false unless @table[r][l] && @table[r][l].color == col
    @checklist.delete block
    @connect_table[-1][:blocks].push block
    return true
  end

  def check_connection(r,l,col)
    return if r < 0 || r >= @row_s
    return if l < 0 || l >= @line_s
    return unless @table[r][l]
    block = @table[r][l]
    cont = block.color == :j ? check_con_jammer(r,l,col,block) :
      check_con_block(r,l,col,block)
    return unless cont
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
      @connect_table.push({:blocks => [], :jammers => []})
      check_connection(r,l,col)
    end
  end

  def eliminate_connection
    @eliminated = !@connect_table.empty? # check flag
    @connect_table.each do |connection|
      # delete blocks
      connection[:blocks].each do |block|
        block.set_collapse(40)
        @table[block.row][block.line] = nil
        @active_blocks.delete block
        @collapse_blocks.push block
      end
      # delete jammers [naive]
      connection[:jammers].each do |jammer|
        next unless @jamming_blocks.include?(jammer) # already be deleted
        jammer.set_collapse(40)
        @table[jammer.row][jammer.line] = nil
        @jamming_blocks.delete jammer
        @collapse_blocks.push jammer
      end
    end
  end

  def fair_connect_table
    @connect_table.select!{|connection| connection[:blocks].size >= 4}
  end

  def eliminate
    @eliminated = false
    make_connect_table
    fair_connect_table
    @chain += 1 unless @connect_table.empty?
    @sm.score += @sm.calc_chain_score(@connect_table, @chain)
    scene = GameMain.scene
    unless @connect_table.empty?
      @jm.jammers += @jm.calc_jammer(@sm.chain_score, @jammer_rate, scene.margin_time, scene.playtime)
    end
    eliminate_connection
    @eliminated
  end

  def start_fall_jammer
    # reset chain
    @chain = 0

    fall_table = @jm.get_fall_table
    fall_table.each.with_index do |jammers, row|
      # col => block
      jammers = jammers.map.with_index{|col, i|
        next unless col
        block = StableBlock.new(col, @block_s)
        block.row = row
        block.line = @line_s + 2 + i # base : linesize + 2[hide block]
        @jamming_blocks.push block
        block
      }
      # extend row to size of @line_s + 2
      @table[row][@line_s + 1] = @table[row][@line_s + 1]
      # concat
      @table[row].concat jammers
    end
  end

  def slice_limited_line
    limit = @line_s + 2
    @row_s.times do |row|
      next if @table[row].size < limit
      @table[row][limit..-1].each do |block|
        @jamming_blocks.delete block
      end
      @table[row] = @table[row][0...limit]
    end
  end

  def get_color_table(tstr)
    table = Array.new(@row_s){ [] }
    tstr.split("\n").reverse.each.with_index do |line, l|
      line.split("").each.with_index do |col,r|
        next if col == "."
        table[r][l] = col.to_sym
      end
    end
    return table
  end

  def set_table(ctbl)
    init_table
    init_blocklist
    @row_s.times do |r|
      ctbl[r].each.with_index do |col, l|
        next unless col
        set(r,l,col)
      end
    end
  end

  def blocks_move_x?
    (@active_blocks + @jamming_blocks).each do |block|
      return true if block.move_x?
    end
    return false
  end
  def blocks_move_y?
    (@active_blocks + @jamming_blocks).each do |block|
      return true if block.move_y?
    end
    return false
  end
  def blocks_move?
    (@active_blocks + @jamming_blocks).each do |block|
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
  def blocks_land?
    (@active_blocks + @jamming_blocks).each do |block|
      return true if block.land?
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
    (@active_blocks + @jamming_blocks).each do |block|
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
    all_blocks.each do |block|
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
