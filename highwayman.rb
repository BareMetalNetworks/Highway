#!/usr/bin/env ruby
require 'json'

srv = Array.new
srv = %w{10.0.1.200 10.0.1.32 10.0.1.26 10.0.1.15 10.0.1.10 10.0.1.7 10.0.1.19 10.0.1.20 10.0.1.21 10.0.1.22 10.0.1
.23 10.0.1.28 10.0.1.29}

opt_parser = OptionParser.new do |opts|
  exec_name = File.basename(PROGRAM_NAME)
  opts.banner = "###### Highwayman IMS ######## \n # BareMetal's Infrastructure Management Console\n
  Usage: #{exec_name} <optional host file> \n

  Will load hosts.json from current directory or /etc/superhighway/hosts.json must be valid JSON"
end

opt_parser.parse!

hosts = ARGV.shift || '/etc/superhighway/hosts.json'

if hosts && File.exists? hosts
  main(hosts)

  # TODO finish this
#elsif #parser
 # `git clone https://github.com/baremetalnetworks/clusterforge`

else
  STDERR.puts "Error: Couldn't find an infrastructure.hosts YAML file, creating one now in /tmp from /etc/hosts"
  `touch /tmp/hosts.json`
  p 'restart the REPL'
  exit 1
end

dpatch = Hash.new(Proc.new)
dpatch[:ssh]

def main()
#def main(hosts_file)
  #servers = JSON.parse(hosts_file)
  command = nil
  cmd_count = 0

  # while commands != ('exit' || 'quit')
  #   command = Readline.readline("#{Time.now}-#{cmd_count.to_s}-IMS> ", true)
  #   cmd_count += 1
  #   break if command.nil?
  #
  #   ## Dispatch table
  #
  # end


end