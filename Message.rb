class Message
	attr_reader :nick
	attr_reader :message

	def initialize(nick, message)
		@nick = nick
		@message = message
	end

	def nick_matches(nick)
		@nick.casecmp(nick) == 0
	end

	def message_contains(message)
		@message.downcase.include? message.downcase
	end
end
