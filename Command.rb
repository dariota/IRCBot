class Command

	def is_command
		false
	end

	def respond ircCommand
		if match ircCommand
			enact ircCommand
		end
	end

	def match ircCommand
		false
	end

end
