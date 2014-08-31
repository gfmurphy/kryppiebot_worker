$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require "commands"
require "json"
require "logger"
require "redis"
require "rufus/scheduler"
require "tweet_popular_message"
require "uri"

default_redis_url = "redis://localhost"

REDIS_URL = URI(ENV["REDISTOGO_URL"] || default_redis_url)
REDIS = Redis.new(url: REDIS_URL.to_s)

$stdout.sync = true
LOGGER = Logger.new($stdout)
LOGGER.level = Logger.const_get ENV["LOG_LEVEL"] || "ERROR"
Logging.logger = LOGGER

Rufus::Scheduler.singleton.every '30m' do
  recent_messages = UserRecentMessages.new(ENV["BFL_USER_ID"], Redis.new(url: REDIS_URL))
  shit_bfl_says   = ShitBflSays.new(ENV["SBFL_SAYS_TOKEN"], ENV["SBFL_SAYS_SECRET"])
  TweetPopularMessage.new(shit_bfl_says).tweet_messages(recent_messages) do |message|
    recent_messages.remove message
  end
end

REDIS.subscribe("groupme:message") do |on|
  on.message do |channel, message|
    data = JSON.parse(message.to_s)
    Commands.handler(data).call(data)
  end
end

