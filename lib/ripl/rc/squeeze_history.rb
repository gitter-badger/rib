
require 'ripl/rc/u'

module Ripl::Rc::SqueezeHistory
  include Ripl::Rc::U

  # avoid some complicated conditions...
  def history
    super || (@history ||= [])
  end

  # write squeezed history
  def write_history
    return super if SqueezeHistory.disabled?
    File.open(history_file, 'w'){ |f|
      f.puts U.squeeze_history(history).join("\n")
    }
  end

  # squeeze history on memory too
  def eval_input input
    return super if SqueezeHistory.disabled?
    history.pop if input.strip == '' ||
                  (history.size > 1 && input == history[-2])
    super
  end

  def before_loop
    return super if SqueezeHistory.disabled?
    super if history.empty?
  end

  module Imp
    def squeeze_history history
      history.to_a.inject([]){ |result, item|
        if result.last == item
          result
        else
          result << item
        end
      }.last(Ripl.config[:rc_squeeze_history_size])
    end
  end
end

module Ripl::Rc::U; extend Ripl::Rc::SqueezeHistory::Imp; end

Ripl::Shell.include(Ripl::Rc::SqueezeHistory)
Ripl.config[:rc_squeeze_history_size] ||= 500
