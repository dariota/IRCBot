require "./Command"

class DotCommand < Command

	def initialize word
		@word = word
	end

	def is_command
		true
	end

	def match command
		command.message.split(" ")[0].casecmp(@word) == 0
	end

end

module Remember

	def enact command
		messageParts = command.message.split " "
		if messageParts.length < 3
			command.bot.say ".remember <nick> <substring>", command.channel
			return
		end
		if messageParts[1].casecmp(command.nick) == 0
			say "You're really not that interesting, #{command.nick}.", command.channel
			return
		end
		
		remembered = command.bot.logger.find(channel, messageParts[1], messageParts[2..-1].join(" ")) unless messageParts.length < 3
		puts "#{remembered.nick}: #{remembered.message}" unless remembered.nil?
	end

end

module Wiki

	def enact command
		index = command.message.index(" ")
		unless index.nil?
			link = search command.message[index+1..-1]
			comand.bot.say link, command.channel
		else
			command.bot.say "#{command.nick}: Please provide a search term.", command.channel
		end
	end

end
