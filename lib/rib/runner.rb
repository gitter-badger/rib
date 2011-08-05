
require 'rib'

module Rib::Runner
  module_function
  def name
    $PROGRAM_NAME
  end

  def options
    { # Ruby OPTIONS
     '-e, --eval LINE'       =>
       'Evaluate a LINE of code'                                      ,

     '-d, --debug'           =>
       'Set debugging flags (set $DEBUG to true)'                     ,

     '-w, --warn'            =>
       'Turn warnings on for your script (set $-w to true)'           ,

     '-I, --include PATH'    =>
       'Specify $LOAD_PATH (may be used more than once)'              ,

     '-r, --require LIBRARY' =>
       'Require the library, before executing your script'            ,

      # Rib OPTIONS
     '-c, --config FILE' => 'Load config from FILE'                   ,
     '-n, --no-config'   => 'Suppress loading ~/.config/rib/config.rb',
     '-h, --help'        => 'Print this message'                      ,
     '-v, --version'     => 'Print the version'                       }
  end

  def run argv=ARGV
    if command = argv.find{ |a| a =~ /^[^-]/ }
      argv.delete(command)
      plugin = "rib-#{command}"
      path   = `which #{plugin}`.strip
      if path == ''
        puts("Can't find `#{plugin}' in $PATH.\n"           \
             "Please make sure `#{plugin}' is installed.\n" \
             "e.g. run `gem install #{plugin}`")
      else
        load(path)
      end
    else
      start(*argv.dup)
    end
  end

  def start *argv
    parse(argv)
    warn "#{name}: Unused arguments: #{argv.inspect}" unless argv.empty?
    Rib.shell.loop
  end

  def parse argv
    until argv.empty?
      case argv.shift
      when /-e=?(.*)/, /--eval=?(.*)/
        eval($1 || argv.shift, __FILE__, __LINE__)

      when '-d', '--debug'
        $DEBUG = true

      when '-w', '--warn'
        $-w = true

      when /-I=?(.*)/, /--include=?(.*)/
        paths = ($1 || argv.shift).split(':')
        $LOAD_PATH.unshift(*paths)

      when /-r=?(.*)/, /--require=?(.*)/
        require($1 || argv.shift)

      when /-c=?(.*)/, /--config=?(.*)/
        Rib.config[:config] = $1 || argv.shift

      when '-n', '--no-config'
        Rib.config.delete(:config)

      when '-h', '--help'
        puts(help)
        exit

      when '-v', '--version'
        require 'rib/version'
        puts(Rib::VERSION)
        exit
      end
    end
  end

  def help
    maxn = options.keys  .map(&:size).max
    maxd = options.values.map(&:size).max
    "Usage: #{name} [Ruby OPTIONS] [Rib COMMAND] [Rib OPTIONS]\n" +
    options.map{ |name, desc|
      sprintf("  %-*s  %-*s", maxn, name, maxd, desc) }.join("\n")
  end
end