#!/usr/bin/env ruby
require 'net/ssh'


def remote_tunnel(host, user, password=nil, localPort, remotePort, remoteIP)
Net::SSH.start(host, user, {:password => password}) do |ssh|
  ssh.forward.remote(2222, 'baremetalnetworks.com', 2222)
  ssh.loop { true }
end