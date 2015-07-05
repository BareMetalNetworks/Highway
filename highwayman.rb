#!/usr/bin/env ruby
require 'json'
require 'optparse'
require 'readline'
require 'highline'
require 'net/ssh'
require 'fuzzy_match'
require 'redis'
require 'redis-objects'
require 'resolv'
require 'connection_pool'
require './lib/liboptions'

$PROGRAM_NAME = 'IMS'
$VERSION = '0.1.0'
###########################################################################################
# Author: SJK, Senior Developer, BareMetalNetworks.com                                    #
# First week of July 2015                                                                 #
##### Future Features #####################################################################
## Populate hosts hostname by calling each ip and running hostname during the setup       #
## Have both batch and single host command issue                                          #
## Write a parser/lexxer for builtins                                                     #
## History support -- redis                                                               #
## Refactor Node into Node                                                                #
## Dispatch table - builtin commands IMS> batch <command>  IMS> host :staged0 <command>   #
## Buildout options table                                                                 #
## Create another class to Manage those nodes?                                            #
## Output to a file or stuff in a database options -- redis                               #
## Batch command execution and cluster management REPL and plain vanilla CLI toolkit      #
## Redis backed store of hostname/node info plus node statistics & command issue returns  #
## Also redis backed store for fuzzymatch future.                                         #
###########################################################################################
begin
##Initialize##
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
    opts.on('-u', '--username [USER]', 'Redis database username') { |u| options[:username] = u || nil}

    options[:host] = nil
    opts.on('-h', '--host [HOST]', 'SSH hostname/ip for single node. Defaults to localhost') { |h|
      options[:host] = h if h =~ Resolv::IPv4::Regex ? true : false }

    options[:port] = '22'
    opts.on('-P', '--port [PORT]', 'SSH node port, default 22'){ |p| options[:port] = p if p.is_a?(Fixnum) }

    options[:pass] = nil
    opts.on('-p', '--password [PASSWORD]', 'SSH node password') { |p| options[:pass] = p || nil }


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

    options[:xprompt] = false
    opts.on('-e', '--extend-prompt', 'Include command completion, history, and push results on a redis :results') {|x|
      options[:xprompt] = true || false}

    options[:repl] = false
    opts.on('-r', '--repl', 'REPL mode, stands for read eval print loop, interactive') {|x|
      options[:repl] = true || false}

    # opts.on('-h', '--help', 'Display the help. Show the available options and usage patterns.') {p opts; exit(1)}
  end ; opt_parser.parse!

## History match/Command completion
## Fuzzymatch.new(['foo', 'bar', 'baz']).find("far")

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
  Redis.new({:host => options[:redishost], :port => options[:redisport], :db => options[:redistable]}) }


$SRVLIST = Redis::List.new('hwy:allnodeIPs') #:marshall => true

  #
  # p $SRVLIST.length
  # p $SRVLIST.values

all_srv = %w{10.0.1.200 10.0.1.32 10.0.1.27 10.0.1.10 10.0.1.7 10.0.1.19 10.0.1.20 10.0.1.21 10.0.1.22 10.0.1.28
10.0.1.29 10.0.1.30 10.0.1.14 10.0.1.16 10.0.1.13 10.0.1.17}
p all_srv.length

srvs = {:datastore0 => '10.0.1.18', :datastore2 => '10.0.1.32', :app2 => '10.0.1.27', :app3 => '10.0.1.28', :app1 => "10
.0..23"}

rescue => err
  p "[INIT] Error during initialization: File #{__FILE__} Line #{__LINE__} #{err.inspect}, #{err.backtrace}"

end


p 'foo'

$XGUI = ARGV.shift || false
#running on xwindows system opt and non xwindows but forward to xwindows opt
# extended prompt yes||No
$EXTENDPROMPT = true


$stack = Array.new

def lexxsexx(expr, opsTable)
  tokens = expr.split(" ")
  tokens.each do |tok|
    type = tok =~ /\A\w+\Z/ ? :tok : nil
    opsTable[type || tok][tok]
  end
end

  class Node
    attr_accessor :host, :user, :password, :sshkey, :running, :results, :hostname, :physHost

    def initialize(host, user, password)
      @host = host
      @user = user
      @password = password
      @results = Array.new
      @running = false
      @sshkey = sshkey
    end

    def shexec(command)
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



def main(srvs, options)
  command = nil
  cmd_count = 0
  conns = Array.new
  options[:password] = nil
  # Construct node objects, keys are hostnames and results is array
  srvs.each {|srv| conns.push(Node.new(srv, options[:user], options[:password] ))}
  ## store hostnames in redis with a 5min expiry

  conns.each {|node| node.hostname = node.shexec('hostname'); node.running = true  }


  # Function issuers, threaded and non-threaded
  threadedcmd = lambda { |conn| Thread.new { conn.results.push(conn.shexec(command)) }}
  #threadedcmd = lambda { |conn| Thread.new { p "### Host #{conn.host} ###\n" + conn.shexec(command) }}
  #issuecmd = lambda { |conn|  p "### Host #{conn.host} ###\n" + conn.shexec(command) }


  begin
    result = []
    while command != ('exit' || 'quit')
      command = Readline.readline("#{Time.now}-#{cmd_count.to_s}-IMS> ")
      break if command.nil?
      cmd_count += 1
      $history.push command if $history.include?(command)
      `notify-send "Issuing command: [#{command}] to host(s) [#{host.keys}]"` if $XGUI
      begin
        conns.each {|conn| threadedcmd.call(conn) if conn.running}

      rescue => err
        pp "[SSH Issuer] Error: #{err.inspect} #{err.backtrace} on #{__FILE__} on line #{__LINE__}"
        next
      end
      p conn.each { |conn| p conn.result}
    end

  rescue => err
    pp "[Main] Error: #{err.inspect} #{err.backtrace} on #{__FILE__} on line #{__LINE__}"
    retry
  end
end

main(all_srv, options)