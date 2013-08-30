#==============================================================================#
#                             field_controller.rb                              #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class FieldController
  attr_reader :field

  def initialize(x,y,row_s, line_s, block_s)
    @x = x; @y = y
    @colors = [:r, :g, :b, :y]
    @row_s = row_s; @line_s = line_s; @block_s = block_s
    @drown_area = [[2,11]]
    @rivals = []
    init_control_block_manager
    init_score_manager
    init_field
    init_phase
  end
  def init_control_block_manager
    @cbm = ControlBlockManager.new
    @cbm.set_type(PivotControlBlock)
  end
  def init_score_manager
    @sm = ScoreManager.new
  end
  def init_field
    @field = Field.new(@row_s, @line_s, @block_s, @drown_area, @cbm, @sm)
  end
  def init_phase
    @phase = Phase.new
    # added :control_block handler
    @phase.add_start_handler(:control_block,
                             method(:start_control_block))
    # added :falldown handler
    @phase.add_condition_handler(:falldown,
                                 method(:falldown_cond))
    # added :elimiate handler
    @phase.add_condition_handler(:eliminate,
                                 method(:eliminate_cond))
    @phase.add_end_handler(:eliminate, :fall_jammer,
                           method(:end_eliminate_to_fall_jammer))
    # added :fall_jammer handler
    @phase.add_start_handler(:fall_jammer,
                         method(:start_fall_jammer))
    @phase.add_condition_handler(:fall_jammer,
                                 method(:fall_jammer_cond))
    @phase.add_end_handler(:fall_jammer, :control_block,
                           method(:end_fall_jammer_to_control_block))
    # added :gameover handler
    @phase.add_condition_handler(:gameover, method(:gameover_cond))
    # added :win handler
    @phase.add_condition_handler(:win, method(:win_cond))

    @phase.change :control_block
  end

  def rivals=(rivals)
    @rivals = rivals
    @field.rivals = rivals
  end

  def update
    #### debug ####
    Debug.print @sm.debug_sprintf
    jm = @field.jm
    Debug.print "#{jm.total_jammers} = #{jm.jammers} + #{jm.total_rivals_buf}"
    ###############
    update_blocks
    draw_field
    return if @phase.dead?
    return if @phase.waiting
    case @phase.phase
    when :phase_trans
      @phase.trans_condition_check
    when :control_block
      update_control_block
    when :falldown
      update_falldown
    when :eliminate
      update_eliminate
    when :fall_jammer
      update_fall_jammer
    when :gameover
      update_gameover
    when :win
      update_win
    end
  end

  def dead?
    @phase.dead?
  end

  def gameover?
    @phase.phase == :gameover
  end

  def rivals_gameover?
    return false if @rivals.empty?
    @rivals.all? {|rival| rival.dead? || rival.gameover? }
  end
  
  def start_control_block
    @cbm.ctrl_block.clear
    pivot = @colors.sample
    belong = @colors.sample
    @field.start_control_block(pivot, belong)
  end
  def start_fall_jammer
    @field.start_fall_jammer
  end
  
  def end_eliminate_to_fall_jammer
    # establish jammers
    @field.jm.establish_jammers
  end
  def end_fall_jammer_to_control_block
    @phase.set_timer(16)
    # delete blocks is over limited line
    @field.slice_limited_line
  end

  def update_control_block
    inputs = [input_move_row?,input_rotate?,
              input_fastfall?,input_momentfall?]
    active = @field.update_control_block(*inputs)
    if active
      @phase.change :win if rivals_gameover?
    else
      @phase.change :falldown
    end
  end
  def update_falldown
    fallen = @field.falldown
    @phase.change :eliminate
  end
  def update_eliminate
    eliminated = @field.eliminate
    if eliminated
      @phase.change :falldown
    else
      @phase.change rivals_gameover? ? :win : :fall_jammer
    end
  end
  def update_fall_jammer
    fallen = @field.falldown(-10, false)
    gameover = @field.check_gameover
    @phase.change (gameover ? :gameover : :control_block)
  end
  def update_gameover
    @phase.wait(60)
    @phase.change :term
  end
  def update_win
    @phase.wait(60)
    @phase.change :term
  end

  def falldown_cond
    # wait fall && land animation
    !@field.blocks_move? && !@field.blocks_land?
  end
  def eliminate_cond
    # wait collapse animation
    !@field.blocks_reasonable_collapse?
  end
  def fall_jammer_cond
    # wait fall && land animation && standard wait
    !@field.blocks_move? && !@field.blocks_land? && @phase.pred_timer
  end
  def gameover_cond
    @phase.kill
  end
  def win_cond
    @phase.kill
  end

  def update_blocks
    @field.update_blocks
  end

  def draw_field
    @field.draw_field(@x,@y)
  end

  def input_move_row?; false; end
  def input_rotate?; false; end
  def input_fastfall?; false; end
  def input_momentfall?; false; end
end
