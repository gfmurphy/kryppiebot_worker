require "kryppiebot"
require "listeners/bfl_parent_comment"
require "listeners/boing"
require "listeners/congrats"
require "listeners/thank_you"
require "logging"
require "user_recent_messages"

module Listeners
  extend self

  @@default_listeners = [
    ->(msg) { Logging.log(:info).message(msg.inspect) },
    ->(msg) { Kryppiebot.redis_pool { |redis| UserRecentMessages.new(msg["user_id"], redis).add msg } },
    ->(msg) { BflParentComment.new(ENV["BFL_USER_ID"], ShitBflSays.new(ENV["SBFL_SAYS_TOKEN"], ENV["SBFL_SAYS_SECRET"])).tweet(msg) },
    ->(msg) { Kryppiebot.redis_pool { |redis| Congrats.new(redis).listen(msg) } },
    ->(msg) { Kryppiebot.redis_pool { |redis| Boing.new(redis).listen(msg) } },
    ->(msg) { ThankYou.new.listen(msg) }
  ].freeze

  def default_listeners
    @@default_listeners
  end
end
