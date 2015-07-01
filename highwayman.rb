#!/usr/bin/env ruby
require 'json'
require 'optparse'
require 'readline'
require 'highline'
require 'net/ssh'

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
password = ARGV.shift || false
$XGUI = ARGV.shift || false
#running on xwindows system opt and non xwindows but forward to xwindows opt
# extended prompt yes||No
$EXTENDPROMPT = true

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

$stack = Array.new

def lexxsexx(expr, opsTable)
  tokens = expr.split(" ")
  tokens.each do |tok|
    type = tok =~ /\A\w+\Z/ ? :tok : nil
    opsTable[type || tok][tok]
  end
end

# dispatch {
#  :sudo => lambda {|x| channel.exec "sudo -p 'sudo password: ' #{command}" do |channel, success|
#    abort "Could not execute sudo #{command} unless success"
#    channel.on_data do |channel, data|
#      print "Connection: #{data}"
#      if data =~ /sudo password: /
#        ch.send_data("password\n")
#
#      end ; end ; end }
# }

# spawn this as a thread
# def sudo_openssh(host, user, password, command)
#   Net::SSH.start(host, user, :password => password) do |ssh|
#     ssh.open_channel do |channel|
#
#     channel.exec "sudo -p 'sudo password: ' #{command}" do |channel, success|
#       abort "Could not execute sudo #{command}" unless success
#       channel.on_data do |channel, data|
#         print "Connection: #{data}"
#         if data =~ /sudo password: /
#           ch.send_data("password\n")
#
#         end
#       end
#     end
#   end
# end

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
            abort "Could not execute #{command}" unless success
            channel.on_data do |channel, data|
              return data

            end
          end
        end
      end
    end
  end

$history = Array.new # for historStringy cache
dpatch = Hash.new
#dpatch[:ssh]

def main(srvs)
#def main(hosts_file)
  #servers = JSON.parse(hosts_file)
  host = srvs
  command = nil
  cmd_count = 0
  conns = Array.new
  conns.push(NodeManager.new('10.0.1.22', 'vishnu', 'password'))

   while command != ('exit' || 'quit')
     #$EXTENDPROMPT ?  command = Readline.readline("#{Time.now}-#{cmd_count.to_s}-IMS> " : command =  "IMS> "
     command = Readline.readline("#{Time.now}-#{cmd_count.to_s}-IMS> ")
     break if command.nil?
     cmd_count += 1
     $history.push command if $history.include?(command)
     `notify-send "Issuing command: [#{command}] to host(s) [#{host.keys}]"` if $XGUI
     conns.each {|conn|
       p "Host #{conn.host}"
       p conn.open_ssh_conn(command)
     }




  #   ## Dispatch table
  #

   end


end

main(srvs)