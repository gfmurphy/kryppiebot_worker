$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require "redis"
require "json"
require "logger"
require "uri"
require "commands"

default_redis_url = "redis://localhost"

uri = URI(ENV["REDISTOGO_URL"] || default_redis_url)
REDIS = Redis.new(url: uri.to_s)

$stdout.sync = true
LOGGER = Logger.new($stdout)
LOGGER.level = Logger.const_get ENV["LOG_LEVEL"] || "ERROR"
Logging.logger = LOGGER

REDIS.subscribe("groupme:message") do |on|
  on.message do |channel, message|
    data = JSON.parse(message.to_s)
    Commands.handler(data).call(data)
  end
end
