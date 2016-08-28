class IrcCommand
	
	attr_reader :nick, :ident, :host, :channel, :message, :bot

	def initialize nick, ident, host, channel, message, bot
		@nick = nick		
		@ident = ident
		@host = host
		@channel = channel
		@message = message
		@bot = bot
	end

end
