require "kryppiebot"
require "listeners/bfl_parent_comment"
require "listeners/boing"
require "listeners/congrats"
require "listeners/grammar_nazi"
require "listeners/thank_you"
require "logging"
require "user_recent_messages"

module Listeners
  extend self

  @@default_listeners = [
    ->(msg) { Logging.log(:info).message(msg.inspect) },
    ->(msg) { Kryppiebot.redis_pool { |redis| UserRecentMessages.new(msg["user_id"], redis).add msg } }
  ].freeze

  def default_listeners
    @@default_listeners
  end
end
