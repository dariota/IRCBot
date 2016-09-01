require "socket"
require "set"
require "./MediaFetch"
require "./Logger"
require "./IrcCommand"
require "./AuthedCommand"
require "./DotCommand"

class WikiBot
	attr_reader :logger

	def initialize(server, port, nick, password = nil)
		@socket = TCPSocket.open(server, port || 6667)
		@socket.puts "PASSWORD #{password}" if password
		nick(nick)
		@socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"

		@channels = Set.new
		@hosts_idents = Hash.new
		@logger = Logger.new
		@commands = Array.new

		sleep 1
		self
	end

	def quit(reason = nil)
		@socket.puts "QUIT :#{reason or ''}"
		@socket.gets until @socket.eof?
	end

	def in_channel?(channel)
		@channels.include? channel.downcase
	end

	def join(channel, password = nil)
		return if in_channel? channel
		@channel_password = password || ""
		@socket.puts "JOIN #{channel} #{@channel_password}"
		@channels.add channel.downcase
	end

	def nick(newNick = "dariobot")
		@socket.puts "NICK #{newNick}"
	end

	def say(message, channel = nil)
		if channel.nil?
			raise ArgumentError unless @channels.length == 1
			channel = "#{@channels.first}"
		end
		join channel unless @channels.member? channel
		@socket.puts "PRIVMSG #{channel} :#{message}"
	end

	def get_messages()
		process_message @socket.gets until @socket.eof?
	end

	def process_message(message)
		puts message
		messageParts = message.split " "

		return ping message if messageParts[0] == "PING"

		senderData = message.match /^:(.+?)!(.+?)@(.+?) (.+?) (.+?) :(.*)/

		return if senderData.nil?

		nick = senderData[1]
		ident = senderData[2]
		host = senderData[3]
		type = senderData[4]
		channel = senderData[5]
		message = senderData[6].chomp
		return if type != "PRIVMSG"

		command = IrcCommand.new nick, ident, host, channel, message, self
		log = true

		@commands.each { |x|
			if x.match command
				x.enact command
				log = false
			end
		}

		@logger.log channel, nick, message if log

		#when ".quote"
		#	return
		#when /https?:\/\/wiki.netsoc.(?:tcd.)?ie/
		#	puts "wiki"
	end

	def ping(message)
		server = (message.split " ")[1]
		@socket.puts "PONG #{server}"
	end

	def admin_authenticated(ident, host)
		idents = @hosts_idents[host.downcase]
		!idents.nil? && idents.member?(ident.downcase)
	end

	def add_admin(ident, host)
		idents = @hosts_idents[host.downcase]
		if idents.nil?
			idents = Set.new
			@hosts_idents[host.downcase] = idents
		end

		idents.add ident.downcase
	end

	def add_command(command)
		@commands.push command unless command.nil?
	end

end
