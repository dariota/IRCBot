require "AuthedCommand"
require "DotCommand"
require "IrcCommand"
require "Logger"
require "WikiBot"

bot = WikiBot.new("irc.netsoc.tcd.ie", 6667, "dariobot")
bot.say "Hey bud", "#dariotest"
bot.add_admin("dario", "spoon.netsoc.tcd.ie")
commands = [AuthedCommand.new(".join").extend(Join), AuthedCommand.new(".quit").extend(Quit), AuthedCommand.new(".nick").extend(Nick), DotCommand.new(".remember").extend(Remember), DotCommand.new(".wiki").extend(Wiki)]
commands.each { |x| bot.add_command x }
bot.get_messages
