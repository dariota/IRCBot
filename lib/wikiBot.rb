require "socket"
require "set"
require "~/ruby/shout-bot/lib/mediaFetch"

class WikiBot
	attr_accessor :channel

	def initialize(server, port, nick, password = nil)
		@socket = TCPSocket.open(server, port || 6667)
		@socket.puts "PASSWORD #{password}" if password
		@socket.puts "NICK #{nick}"
		@socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
		@channels = Set.new
		sleep 1
		self
	end

	def quit(reason = nil)
		@socket.puts "QUIT :#{reason or ''}"
		@socket.gets until @socket.eof?
	end

	def join(chanName, password = nil)
		channel = "##{chanName}"
		@channel_password = password || ""
		@socket.puts "JOIN #{channel} #{@channel_password}"
		@channels.add chanName
	end

	def say(message, channel = nil)
		if channel.nil?
			raise ArgumentError unless @channels.length == 1
			channel = @channels.first
		end
		join channel unless @channels.member? channel
		@socket.puts "PRIVMSG #{@channel} :#{message}"
	end

end

bot = WikiBot.new("irc.netsoc.tcd.ie", 6667, "dariobot")
bot.say "Hey bud", "#dariotest"
bot.quit
