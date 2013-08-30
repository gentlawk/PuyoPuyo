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
    @wait = 0                     # wait count
    @timer = 0                    # timer
  end

  def add_handler(handler, args)
    case args.size
    when 2
      phase, method = args
      handler[phase] = method
    when 3 # don't care of old/new phase
      phase1, phase2, method = args
      handler[[phase1,phase2]] = method
    else
      raise(ArgumentError, "wrong number of arguments (#{args.size} for 2 or 3)")
    end
  end

  def add_start_handler(*args)
    # phase, method # don't care of oldphase
    # phase, oldphase, method
    add_handler(@start_handler, args)
  end
  def add_end_handler(*args)
    # phase, method # don't care of nextphase
    # phase, nextphase, method
    add_handler(@end_handler, args)
  end
  def add_condition_handler(*args)
    # oldphase, method # don't care of nextphase
    # oldphase, nextphase, method
    add_handler(@trans_condition_handler, args)
  end

  def get_handler(handler, phase1, phase2)
    method = handler[[phase1, phase2]]
    method = handler[phase1] unless method
    return method
  end

  def phase
    @next_phase ? :phase_trans : @phase
  end

  def trans_condition_check
    cond = get_handler(@trans_condition_handler, @phase, @next_phase)
    return if cond && !cond.call
    old = @phase
    @phase = @next_phase
    @next_phase = nil
    # start handler
    method = get_handler(@start_handler, @phase, old)
    method.call if method
  end

  def change(phase)
    # end handler
    method = get_handler(@end_handler, @phase, phase)
    method.call if method
    # set next_phase
    @next_phase = phase
    # trans condition check
    trans_condition_check unless wait?
  end

  def wait(time)
    @wait = time
  end
  def wait?
    @wait > 0
  end
  def waiting
    return false unless wait?
    @wait -= 1
    return true
  end
  def set_timer(time)
    @timer = time
  end
  def pred_timer
    return true if !timer?
    @timer -= 1
    !timer?
  end
  def timer?
    @timer > 0
  end
end
