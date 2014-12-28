require "commands/echo_command"
require "commands/leaderboard_command"
require "commands/null_command"
require "commands/ping_command"
require "group_me"
require "null_cache"
require "listeners"


module Commands
  extend self

  COMMAND_PREFIX = /^!kryppiebot,?\s+/i

  @commands = {
    "echo" => -> (message) { EchoCommand.new(message).execute },
    "ping" => -> (message) { PingCommand.new.execute },
    "leaderboard" => -> (message) { LeaderboardCommand.new(redis_cache, message).execute }
  }

  def handler(message)
    text = message["text"].to_s
    if COMMAND_PREFIX =~ text
      fetch(text.split(/\s+/)[1].to_s.downcase) { NullCommand.new }
    else
      ->(msg) {
        Listeners.new(Listeners.default_listeners).each do |listener|
          listener.call(msg)
        end
      }
    end
  end

  def fetch(key, &b)
    @commands.fetch(key, &b)
  end

  private
  def redis_cache
    NullCache.new
  end
end
