require 'rye'
require 'redis'
require 'redis-objects'
require 'pp'
require 'connection_pool'


$o = {}
$o[:redisHost] = '10.0.1.17' || ARGV[0]
$o[:redisPort] = '6379' || ARGV[1]
$o[:redisTable] = '0' || ARGV[2]

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
	Redis.new({:host => $o[:redisHost], :port => $o[:redisPort], :db => $o[:redisTable]}) }

$SRV = Redis::List.new('Nodes') #:marshall => true

def load_hosts
p $SRV
hosts = %w{datastore0 datastore1 datastore2 datastore3 app0 app1 app2 app3 app4 app5 app6 dev0 dev1 dev2 dev3 manager0 devops0 stack0}
$SRV.clear
hosts.map {|host| $SRV << host }
$SRV.values
end

p $SRV.values
p box = Rye::Box.new("datastore2", :safe => false)
ret = box.uptime
p ret.stdout


