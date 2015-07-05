options = {}
opt_parser = OptionParser.new do |opts|
  exec_name = File.basename($PROGRAM_NAME)
  opts.banner = "###### Highway IMS ######## \n # BareMetal's Infrastructure Management Console\n
# GNU Readline supported Ctrl-* and Alt-* emacs keybindings available\n
  Usage: #{exec_name} <options> \n""   "

  options[:version] = false
  opts.on('-v', '--[no]-verbose', 'Increase detail in output') { |v| options[:verbose] = v if v}

  options[:logfile] = nil
  opts.on('-l', '--logfile [FILE]', 'Write output to a file') { |f| options[:logfile] = f || false }

  options[:username] = nil
  opts.on('-u', '--username [REDIS-USER]', 'Redis database username') { |u| options[:username] = u || nil}

  options[:redishost] = '127.0.0.1'
  opts.on('-h', '--host [REDIS-HOST]', 'Redis database host. Defaults to localhost') { |h|
    options[:redishost] = h if h =~ Resolv::IPv4::Regex ? true : false }

  options[:redisport] = '6379'
  opts.on('-P', '--port [REDIS-PORT]', 'Redis database host port'){ |p| options[:redisport] = p if p.is_a?(Fixnum) }

  options[:redispass] = nil
  opts.on('-p', '--password [REDIS-PASSWORD]', 'Redis database password') { |p| options[:redispass] = p || nil }

  options[:redistable] = 1
  opts.on('-t', '--redis-table [REDIS-TABLE]', 'Redis table number, must be a fixnum e.g. 1 or 3'){ |d|
    options[:redistable] = d if d.is_a?(Fixnum)}

  options[:xgui] = false
  opts.on('-x', '--x-windows-notify', 'Use this if you and want notifications sent to X Windows') {|x|
    options[:xgui] = true || false}

  opts.on('-h', '--help', 'Display the help. Show the available options and usage patterns.') {p opts; exit(1)}


end ; opt_parser.parse!