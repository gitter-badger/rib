
require 'rib'

module Rib::StripBacktrace
  extend Rib::Plugin
  Shell.use(self)

  # --------------- Rib API ---------------

  def format_error err
    return super if StripBacktrace.disabled?
    message, backtrace = get_error(err)
    "#{message}\n  #{backtrace.join("\n  ")}"
  end

  def get_error err
    return super if StripBacktrace.disabled?
    ["#{err.class}: #{err.message}", strip_backtrace(err.backtrace)]
  end



  module_function
  def strip_backtrace backtrace
    strip_home_backtrace(strip_cwd_backtrace(strip_lib_backtrace(backtrace)))
  end

  def strip_home_backtrace backtrace
    backtrace.map{ |path| path.sub(ENV['HOME'], '~') }
  end

  def strip_cwd_backtrace backtrace
    backtrace.map{ |path| path.sub(Dir.pwd, '.') }
  end

  def strip_lib_backtrace backtrace
    backtrace[
      0..backtrace.rindex{ |l| l =~ /\(#{name}\):\d+:in `.+?'/ } || -1]
  end
end
