require 'rye'
require 'redis'
require 'redis-objects'
require 'pp'
require 'connection_pool'
$DBG = true
## INIT ##############################################################################################
$o = {}
$o[:redisHost] = '10.0.1.17' || ARGV[0]
$o[:redisPort] = '6379' || ARGV[1]
$o[:redisTable] = '0' || ARGV[2]

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
	Redis.new({:host => $o[:redisHost], :port => $o[:redisPort], :db => $o[:redisTable]}) }

SRVLIST = Redis::List.new('Nodes') #:marshall => true
boxes = []
 SRVLIST.each {|srv| boxes.push(Rye::Box.new(srv, :safe => false)); boxes}
p boxes if $DBG
cluster = Rye::Set.new
cluster.parallel = true
SRVLIST.each {|srv| cluster.add_boxes srv}
p boxes if $DBG


def load_phys_hosts(srvs)
	physical = Rye::Set.new
	physical.parallel = true
	hosts = %{atlas archangel neptune}
	srvs.map{ |host| host}
end

def load_hosts(srvs)

hosts = %w{datastore0 datastore1 datastore2 datastore3 app0 app1 app2 app3 app4 app5 app6 dev0 dev1 dev2 dev3 manager0 devops0 stack0}
srvs.clear
hosts.map {|host| srvs << host }
srvs.values
end
## END INIT ####################################################################################

def get_vm_status

end

def batch_exec

end


__END__
p $SRV.values
p box = Rye::Box.new("datastore2", :safe => false)
ret = box.uptime
p ret.stdout


