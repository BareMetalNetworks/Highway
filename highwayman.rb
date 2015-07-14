#!/usr/bin/env ruby
require 'json'
require 'optparse'
require 'readline'
require 'highline'
require 'pp'
#require 'net/ssh'
#require 'fuzzy_match'
require 'redis'
require 'redis-objects'
require 'redis/list'
require 'redis/hash_key'


#require 'resolv'
require 'connection_pool'
#require './lib/liboptions'
require 'rye'

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

__END__

sudo sm


Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
Redis.new({:host => options[:redishost], :port => options[:redisport], :db => options[:redistable]}) }


$SRVLIST = Redis::List.new('hwy:allHosts') #:marshall => true



all_srv = %w{10.0.1.200 10.0.1.32 10.0.1.27 10.0.1.10 10.0.1.7 10.0.1.19 10.0.1.20 10.0.1.21 10.0.1.22 10.0.1.28
10.0.1.29 10.0.1.30 10.0.1.14 10.0.1.16 10.0.1.13 10.0.1.17}
p all_srv.length

srvs = {:datastore0 => '10.0.1.18', :datastore2 => '10.0.1.32', :app2 => '10.0.1.27', :app3 => '10.0.1.28', :app1 => "10
.0..23"}

hosts = %w{datastore0 datastore1 datastore2 datastore3 app0 app1 app2 app3 app4 app5 app6 dev0 dev1 dev2 dev3 manager0 devops0 stack0}

p hosts.length
#$SRVLIST.push hosts unless $SRVLIST.length < 14


=begin
p "[INIT] Error during initialization: File #{__FILE__} Line #{__LINE__} #{err.inspect}, #{err.backtrace}"
=end


class Cluhstir
attr_accessor :stats, :exek, :master

def initialize(srvs)
# use a struct?
@xs = Hash.new
@master = Rye::Set.new
@master.parallel = true
srvs.each {|srv| @xs[:srv] = Rye::Box.new srv, :safe => false
@master.add_boxes @xs[:srv] }
@stats = Hash.new(Hash.new)
# loads = Hash.new
# mems = Hash.new
# tcps = Hash.new
# udps = Hash.new
# nets = Hash.new
# disks = Hash.new
end

def pull_the_trigger

end

def loads
@srvs.each {|s| s.uptime; }
end


end


def
def repl(srvs)
cluster = Cluhstir.new(srvs)
aoa = cluster.master.uptime
aoa.each {|res| res.each { |re| pp re.class }}

end

repl(srvs)





__END__

def main(srvs, options)
command = nil
cmd_count = 0
nodes = Hash.new
srvs.each {|srv| nodes[:srv] = Rye::Box.new(srv)


begin
result = []
while command != ('exit' || 'quit'|| 'q')
command = Readline.readline("#{Time.now}-#{cmd_count.to_s}-IMS> ")
break if command.nil?
cmd_count += 1
Readline::HISTORY.push(command)

`notify-send "Issuing command: [#{command}] to host(s) [#{host.keys}]"` if $XGUI
begin
nodes.each{ |node| p nodes[node].uptime }
# conns.each {|conn| threadedcmd.call(conn) if conn.running}

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