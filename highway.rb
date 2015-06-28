#!/usr/bin/env ruby
require 'json'

opt_parser = OptionParser.new do |opts|
  exec_name = File.basename(PROGRAM_NAME)
  opts.banner = "###### BMN IMS ######## \n # BareMetal's Infrastructure Management Console\n
  Usage: #{exec_name} <optional host file> \n

  Will load hosts.json from current directory or /etc/superhighway/hosts.json must be valid JSON"
end

opt_parser.parse!

hosts = ARGV.shift || '/etc/superhighway/hosts.json'

if hosts && File.exists? hosts
  main(hosts)
=begin
else
  STDERR.puts "Error: Couldn't find an infrastructure.hosts YAML file, creating one now in /tmp"
  `touch /tmp/hosts.json`
  p 'restart the REPL'
  exit 1
=end
end

def main(hosts_file)
  servers = JSON.parse(hosts_file)
80
end