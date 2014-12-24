require "logging/log"
require "logging/null_logger"

module Logging
  extend self

  def logger=(logger)
    if logger.nil?
      @logger = NullLogger.new
    else
      @logger = logger
    end
  end

  def logger
    @logger = NullLogger.new unless defined?(@logger)
    @logger
  end

  def log(level=:info)
    log_proc = {
      error: ->(message) { logger.error(message) },
      warn:  ->(message) { logger.warn(message) },
      debug: ->(message) { logger.debug(message) },
      fatal: ->(message) { logger.fatal(message) }
    }.fetch(level) { ->(message){ logger.info(message) } }
    Log.new(log_proc)
  end
end
