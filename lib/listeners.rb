require "listeners/bfl_parent_comment"
require "listeners/congrats"
require "logging"
require "redis"
require "user_recent_messages"

module Listeners
  extend self

  def default_listeners
    [
      ->(msg) { Logging.log(:info).message(msg.inspect) },
      ->(msg) { UserRecentMessages.new(msg["user_id"], Redis.new(url: REDIS_URL)).add msg },
      ->(msg) { BflParentComment.new(ENV["BFL_USER_ID"], ShitBflSays.new(ENV["SBFL_SAYS_TOKEN"], ENV["SBFL_SAYS_SECRET"])).tweet(msg) },
      ->(msg) { Congrats.new(Redis.new(url: REDIS_URL)).listen(msg) }
    ]
  end
end
