

dispatch {
  'bar' => lambda {|x| p x},
 :sudo => lambda {|x| channel.exec "sudo -p 'sudo password: ' #{command}" do |channel, success|
   abort "Could not execute sudo #{command} unless success"
   channel.on_data do |channel, data|
     retstr += "Connection: #{data}"
     if data =~ /sudo password: /
       ch.send_data("password\n")
     end ; return retstr ; end ; end },
  :foo => lambda {|x| }
}


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