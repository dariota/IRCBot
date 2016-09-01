require "./RingBuffer"
require "./Message"

LOG_LENGTH = 100

class Logger

	def initialize(channels = nil)
		@logs = Hash.new
		channels.each {|c| add_channel c} unless channels.nil?  
	end

	def add_channel(channel)
		@logs[channel.downcase] = RingBuffer.new LOG_LENGTH unless channel.nil?
	end

	def log(channel, nick, message)
		if @logs[channel.downcase].nil?
			add_channel channel
		end

		logs = @logs[channel.downcase]
		logs << Message.new(nick, message)
	end

	def find(channel, nick, messagePart)
		if @logs[channel.downcase].nil? # should be impossible, but hey
			return nil
		end

		@logs[channel.downcase].find { |m| m.nick_matches(nick) && m.message_contains(messagePart) }
	end

	def print
		puts @logs
	end
end
