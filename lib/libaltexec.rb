


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

def alt_repl(srvs, options)
	command = nil
	cmd_count = 0
	nodes = Hash.new
	options[:password] = nil
	# Construct node objects, keys are hostnames and results is array
	#rvs.each {|srv| conns.push(Node.new(srv, options[:user], options[:password] ))}
	## store hostnames in redis with a 5min expiry
	srvs.each {|srv| nodes[:srv] = Rye::Box.new(srv)
	#conns.each {|node| node.hostname = node.shexec('hostname'); node.running = true  }


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

	#main(all_srv, options)