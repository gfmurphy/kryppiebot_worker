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

  def handler(message)
    text = message["text"].to_s
    if text =~ COMMAND_PREFIX
      fetch_command(message)
    else
      -> {
        Listeners.default_listeners.each do |listener|
          listener.call(message)
        end
      }
    end
  end

  private
  def redis_cache
    NullCache.new
  end

  def fetch_command(message)
    command = message["text"].to_s.split(/\s+/)[1].to_s.downcase
    { "echo" => -> { EchoCommand.new(message).execute },
      "ping" => -> { PingCommand.new.execute },
      "leaderboard" => -> { LeaderboardCommand.new(redis_cache, message).execute }
    }.fetch(command) { -> { NullCommand.new(message).execute } }
  end
end
