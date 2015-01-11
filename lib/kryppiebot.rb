require "connection_pool"
require "logger"
require "redis"
require "uri"

module Kryppiebot
  REDIS_URL = URI(ENV["REDISTOGO_URL"] || "redis://localhost")
  
  @redis  = ConnectionPool.new(size: 7, timeout: 5) { Redis.new(url: REDIS_URL) }
  @logger = Logger.new($stdout).tap { |l| l.level = Logger.const_get(ENV["LOG_LEVEL"] || "ERROR") }

  module_function

  def redis_pool(&b)
    @redis.with(&b)
  end

  def redis
    Redis.new(url: REDIS_URL)
  end

  def logger
    @logger
  end
end
