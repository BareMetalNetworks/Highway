#!/usr/bin/env ruby
require 'json'
require 'optparse'
require 'readline'
require 'highline'
require 'net/ssh'
require 'fuzzy_match'
# Author: SJK, Senior Developer, BareMetalNetworks Corp
# First week of July 2015

## Fuzzymatch.new(['foo', 'bar', 'baz']).find("far")
all_srv = Array.new
all_srv = %w{10.0.1.200 10.0.1.32 10.0.1.27 10.0.1.10 10.0.1.7 10.0.1.19 10.0.1.20 10.0.1.21 10.0.1.22 10.0.1.28}

srvs = {:datastore0 => '10.0.1.18', :datastore2 => '10.0.1.32', :app2 => '10.0.1.27', :app3 => '10.0.1.28', :app1 => "10
.0..23"}

opt_parser = OptionParser.new do |opts|
  exec_name = File.basename($PROGRAM_NAME)
  opts.banner = "###### Highway IMS ######## \n # BareMetal's Infrastructure Management Console\n
  # GNU Readline supported ctr-X and Alt-X emacs keybindings available\n
  Usage: #{exec_name} <optional host file> \n

  Will load hosts.json from current directory or /etc/superhighway/hosts.json must be valid JSON"
end

opt_parser.parse!

hosts = ARGV.shift || '/etc/superhighway/hosts.json'
password = ARGV.shift || false
$XGUI = ARGV.shift || false
#running on xwindows system opt and non xwindows but forward to xwindows opt
# extended prompt yes||No
$EXTENDPROMPT = true

# if hosts && File.exists?(hosts)
#   main(hosts)
#
#   # TODO finish this
# #elsif #parser
#  # `git clone https://github.com/baremetalnetworks/clusterforge`
#
# else
#   STDERR.puts "Error: Couldn't find an infrastructure.hosts YAML file, creating one now in /tmp from /etc/hosts"
#   `touch /tmp/hosts.json`
#   p 'restart the REPL'
#   #exit 1
# end

$stack = Array.new

def lexxsexx(expr, opsTable)
  tokens = expr.split(" ")
  tokens.each do |tok|
    type = tok =~ /\A\w+\Z/ ? :tok : nil
    opsTable[type || tok][tok]
  end
end

  class NodeManager
    attr_accessor :host, :user, :password

    def initialize(host, user, password)
      @host = host
      @user = user
      @password = password
      #@key = key
    end
    def open_ssh_conn(command)
      Net::SSH.start(@host, @user, :password => @password) do |ssh|
        ssh.open_channel do |channel|
          channel.exec command do |channel, success|
            raise "Could not execute #{command}" unless success
            channel.on_data do |channel, data|
              return data

            end
          end
        end
      end
    end
  end

$history = Array.new # for history cache

##### Future Features #####
## Populate hosts hostname by calling each ip and running hostname during the setup
## Have both batch and single host command issue
## Write a parser/lexxer for builtins
## History support
## Refactor NodeManager into Node
## Dispatch table for builtin commands IMS> batch <command>  IMS> host :staged0 <command>
## Buildout options table
## Create another class to Manage those nodes?
## Output to a file or stuff in a database options
###########################

def main(srvs)
  command = nil
  cmd_count = 0
  conns = Array.new
  nodeRes = Hash.new([])

  # Function issuers, threaded and non-threaded
  threadedcmd = lambda { |conn| Thread.new { nodeRes[conn.host].push(conn.open_ssh_conn(command)) }}
  #threadedcmd = lambda { |conn| Thread.new { p "### Host #{conn.host} ###\n" + conn.open_ssh_conn(command) }}
  issuecmd = lambda { |conn|  p "### Host #{conn.host} ###\n" + conn.open_ssh_conn(command) }

  # Construct node objects, populate them with hash: keys are hostnames and value is array for results
  srvs.each {|srv| conns.push(NodeManager.new(srv, 'vishnu', 'password' ))}
  conns.each {|conn| h = conn.open_ssh_conn('hostname'); nodeRes[h.chomp.to_s.to_sym] = ['alive']  }

  begin
    while command != ('exit' || 'quit')
      command = Readline.readline("#{Time.now}-#{cmd_count.to_s}-IMS> ")
      break if command.nil?
      cmd_count += 1
      $history.push command if $history.include?(command)
      `notify-send "Issuing command: [#{command}] to host(s) [#{host.keys}]"` if $XGUI
      begin
        conns.each {|conn| threadedcmd.call(conn)}

      rescue => err
        p "[Issuer] Error: #{err.inspect}"
        next
      end
      p nodeRes
    end

  rescue => err
    p "[Main] Error: #{err.inspect}"
    retry
  end
end

main(all_srv)