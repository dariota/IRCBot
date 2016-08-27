require "socket"
require "set"
require "./mediaFetch"

class WikiBot
	attr_accessor :channel

	def initialize(server, port, nick, password = nil)
		@socket = TCPSocket.open(server, port || 6667)
		@socket.puts "PASSWORD #{password}" if password
		@socket.puts "NICK #{nick}"
		@socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
		@channels = Set.new
		@hosts_idents = Hash.new
		sleep 1
		self
	end

	def quit(reason = nil)
		@socket.puts "QUIT :#{reason or ''}"
		@socket.gets until @socket.eof?
	end

	def join(chanName, password = nil)
		channel = "#{chanName}"
		@channel_password = password || ""
		@socket.puts "JOIN #{channel} #{@channel_password}"
		@channels.add chanName
	end

	def nick(newNick = "dariobot")
		@socket.puts"NICK #{newNick}"
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

		if messageParts[0] == "PING"
			return ping message
		end

		senderData = message.match /^:(.+?)!(.+?)@(.+?) (.+?) (.+?) :(.*)/

		return if senderData.nil?

		nick = senderData[1]
		ident = senderData[2]
		host = senderData[3]
		type = senderData[4]
		channel = senderData[5]
		message = senderData[6].chomp
		return if type != "PRIVMSG"

		messageParts = message.split(" ")

		case messageParts[0]
		when ".quit"
			quit "Received quit command from #{nick}." if admin_authenticated(ident, host)
		when ".nick"
			return unless admin_authenticated(ident, host)
			nick(messageParts[1])
		when ".remember"
			puts "remem"
		when ".quote"
			puts "quote"
		when /https?:\/\/wiki.netsoc.(?:tcd.)?ie/
			puts "wiki"
		end
	end

	def ping(message)
		puts "got ping"
		server = (message.split " ")
		@socket.puts "PONG #{server}"
	end

	def admin_authenticated(ident, host)
		host.downcase!
		ident.downcase!
		idents = @hosts_idents[host]
		!idents.nil? && idents.member?(ident)
	end

	def add_admin(ident, host)
		ident.downcase!
		host.downcase!

		idents = @hosts_idents[host]
		if idents.nil?
			idents = Set.new
			@hosts_idents[host] = idents
		end

		idents.add ident
	end

end

bot = WikiBot.new("irc.netsoc.tcd.ie", 6667, "dariobot")
bot.say "Hey bud", "#dariotest"
bot.add_admin("dario", "spoon.netsoc.tcd.ie")
bot.get_messages
