require "./DotCommand"

class AuthedCommand < DotCommand

	def match command
		if super(command)
			return command.bot.say("You're not authorised to do that.", command.channel) unless command.bot.admin_authenticated(command.ident, command.host)
			true
		end
	end

end

module Join

	def enact command
		parts = command.message.split(" ")
		channel, password = parts[1], parts[2]
		return if channel.nil? || command.bot.in_channel?(channel)

		command.bot.join parts[1], parts[2]
		command.bot.say "Joined on request of #{command.nick}.", channel
	end

end	

module Quit

	def enact command
		command.bot.quit "Received quit command from #{command.nick}."
	end

end

module Nick

	def enact command
		newNick = command.message.split(" ")[1]
		if newNick.nil?
			command.bot.nick
		else
			command.bot.nick newNick
		end
	end

end
