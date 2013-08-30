#==============================================================================#
#                                   phase.rb                                   #
#------------------------------------------------------------------------------#
#                       @copyright (c) 2013, BlueRedZone                       #
#                               @author gentlawk                               #
#==============================================================================#
class Phase
  def initialize
    @start_handler = {}           # call method when phase starting
    @end_handler = {}             # call method before phase changing
    @trans_condition_handler = {} # call method of phase change condition
    @phase = nil                  # present phase
    @next_phase = nil             # next phase
  end

  def add_start_handler(phase, method)
    @start_handler[phase] = method
  end
  def add_end_handler(phase, method)
    @end_handler[phase] = method
  end
  def add_condition_handler(prephase, nextphase, cond)
    @trans_condition_handler[[prephase,nextphase]] = cond
  end

  def phase
    @next_phase ? :phase_trans : @phase
  end

  def trans_condition_check
    cond = @trans_condition_handler[[@phase,@next_phase]]
    return if cond && !cond.call
    @phase = @next_phase
    @next_phase = nil
    # start handler
    method = @start_handler[@phase]
    method.call if method
  end

  def change(phase)
    # end handler
    method = @end_handler[@phase]
    method.call if method
    # set next_phase
    @next_phase = phase
    # trans condition check
    trans_condition_check
  end
end
