require "redis"
require "json"
require "logger"
require "uri"

default_redis_url = "redis://localhost"

uri = URI(ENV["REDISTOGO_URL"] || default_redis_url)
REDIS = Redis.new(url: uri.to_s)

$stdout.sync = true
LOGGER = Logger.new($stdout)
LOGGER.level = Logger.const_get ENV["LOG_LEVEL"] || "ERROR"

REDIS.subscribe("groupme:message") do |on|
  on.message do |channel, message|
    data = JSON.parse(message.to_s)
    LOGGER.debug("Message received: %s" % data.inspect)
  end
end
