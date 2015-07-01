#!/usr/bin/env ruby
require 'json'
require 'optparse'
require 'readline'

all_srv = Array.new
all_srv = %w{10.0.1.200 10.0.1.32 10.0.1.26 10.0.1.15 10.0.1.10 10.0.1.7 10.0.1.19 10.0.1.20 10.0.1.21 10.0.1.22 10.0.1
.23 10.0.1.28 10.0.1.29}

srvs = {:datastore0 => '10.0.1.18', :datastore2 => '10.0.1.32', :app2 => '10.0.1.27', :app3 => '10.0.1.28', :app1 => "10
.0..23"}
opt_parser = OptionParser.new do |opts|
  exec_name = File.basename($PROGRAM_NAME)
  opts.banner = "###### Highwayman IMS ######## \n # BareMetal's Infrastructure Management Console\n
  Usage: #{exec_name} <optional host file> \n

  Will load hosts.json from current directory or /etc/superhighway/hosts.json must be valid JSON"
end

opt_parser.parse!

hosts = ARGV.shift || '/etc/superhighway/hosts.json'

if hosts && File.exists?(hosts)
  main(hosts)

  # TODO finish this
#elsif #parser
 # `git clone https://github.com/baremetalnetworks/clusterforge`

else
  STDERR.puts "Error: Couldn't find an infrastructure.hosts YAML file, creating one now in /tmp from /etc/hosts"
  `touch /tmp/hosts.json`
  p 'restart the REPL'
  #exit 1
end

dpatch = Hash.new
#dpatch[:ssh]

def main(srvs)
#def main(hosts_file)
  #servers = JSON.parse(hosts_file)
  hsts = srvs
  command = nil
  cmd_count = 0

   while command != ('exit' || 'quit')
     command = Readline.readline("#{Time.now}-#{cmd_count.to_s}-IMS> ", true)
     break if command.nil?
     cmd_count += 1
     `notify-send "Issuing command: #{command} to host(s) #{hsts}"`

  #   ## Dispatch table
  #
   end


end

main(srvs)