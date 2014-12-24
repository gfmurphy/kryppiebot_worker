require "logging"
require "redis"
require "user_recent_messages"

class Listeners
  def self.default_listeners
    [
      ->(msg) { Logging.log(:info).message(msg.inspect) },
      ->(msg) { UserRecentMessages.new(msg["user_id"], Redis.new(url: REDIS_URL)).add msg }
    ]
  end

  def initialize(default_listeners)
    @listeners = Array(default_listeners)
  end

  def each(&b)
    @listeners.each(&b)
  end
end
