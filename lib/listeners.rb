require "kryppiebot"
require "listeners/thank_you"
require "logging"

module Listeners
  @default_listeners = [
    ->(msg) { Logging.log(:info).message(msg.inspect) },
    ->(msg) { ThankYou.new.listen(msg) }
  ].freeze

  def self.default_listeners
    @default_listeners
  end
end
