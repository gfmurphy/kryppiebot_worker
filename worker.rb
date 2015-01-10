$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require "celebration_feed"
require "commands"
require "image_set"
require "json"
require "logger"
require "redis"
require "rufus/scheduler"
require "shit_bfl_says"
require "tweet_popular_message"
require "twitter"
require "uri"
require "user_recent_messages"

default_redis_url = "redis://localhost"

REDIS_URL = URI(ENV["REDISTOGO_URL"] || default_redis_url)
REDIS = Redis.new(url: REDIS_URL.to_s)

$stdout.sync = true
LOGGER = Logger.new($stdout)
LOGGER.level = Logger.const_get ENV["LOG_LEVEL"] || "ERROR"
Logging.logger = LOGGER

Rufus::Scheduler.singleton.every '5m' do
  TweetPopularMessage.watch_bfl(Redis.new(url: REDIS_URL))
end

Rufus::Scheduler.singleton.cron '0 */3 * * *' do
  CelebrationFeed.add_image_urls(ENV["CELEBRATE_URL"], ImageSet.new("celebrate", Redis.new(url: REDIS_URL)))
end

REDIS.subscribe("groupme:message") do |on|
  on.message do |channel, message|
    Commands.handler(JSON.parse(message.to_s)).call
  end
end

