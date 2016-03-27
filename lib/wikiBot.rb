require "addressable/uri"
require "socket"

class ShoutBot
  def self.shout(uri, password = nil, &block)
    raise ArgumentError unless block_given?

    uri = Addressable::URI.parse(uri)
    irc = new(uri.host, uri.port, uri.user, uri.password) do |irc|
      if channel = uri.fragment
        irc.join(channel, password, &block)
      else
        irc.channel = uri.path[1..-1]
        yield irc
      end
    end
  end

  attr_accessor :channel

  def initialize(server, port, nick, password=nil)
    raise ArgumentError unless block_given?

    @socket = TCPSocket.open(server, port || 6667)
    @socket.puts "PASSWORD #{password}" if password
    @socket.puts "NICK #{nick}"
    @socket.puts "USER #{nick} #{nick} #{nick} :#{nick}"
    sleep 1
    yield self
    @socket.puts "QUIT"
    @socket.gets until @socket.eof?
  end

  def join(channel, password = nil)
    raise ArgumentError unless block_given?
    params = channel.split('?')
    @channel = "##{params[0]}"
    @channel_password = params[1] || password || ""
    @socket.puts "JOIN #{@channel} #{@channel_password}"
    yield self
    @socket.puts "PART #{@channel}"
  end

  def say(message)
    return unless @channel
    @socket.puts "PRIVMSG #{@channel} :#{message}"
  end
end
