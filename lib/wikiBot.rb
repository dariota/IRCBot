require "socket"
require "./mediaFetch"

class WikiBot
	attr_accessor :channel

	def initialize(server, port, nick, password = nil)
		@socket = TCPSocket.open(server, port || 6667)
		@socket.puts "PASSWORD #{password}" if password
		@socket.puts "NICK #{nick}"
		@socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
		sleep 1
		self
	end

	def quit(reason = nil)
		@socket.puts "QUIT :#{reason or ''}"
		@socket.gets until @socket.eof?
	end

	def join(channel, password = nil)
		raise ArgumentError unless block_given?
		params = channel.split('?')
		@channel = "##{params[0]}"
		@channel_password = params[1] || password || ""
		@socket.puts "JOIN #{@channel} #{@channel_password}"
		yield self
	end

	def say(message)
		return unless @channel
		@socket.puts "PRIVMSG #{@channel} :#{message}"
	end

	def get_messages()
		process_message @socket.gets until @socket.eof?
	end

	def process_message(message)
		puts message
		case
		when message.start_with? ".quit"

		when message.start_with? ".remember"

		when message.start_with? ".quote"

		when message.include? /https?:\/\/wiki.netsoc.(?:tcd.)?ie/
		end
	end

end

bot = WikiBot.new("irc.netsoc.tcd.ie", 6667, "dariobot")
bot.join("dariotest") do |bot|
	bot.say "hello"
end
bot.quit
