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

  class NullLogger
    [:error, :warn, :debug, :info, :fatal].each do |meth| 
      define_method meth do |message| 
        # NO OP
      end
    end
  end

  class Log
    def initialize(logger)
      @logger = logger
    end

    def message(message)
      @logger.call(message)
    end

    def error(exception)
      @logger.call(exception.message)
      @logger.call(exception.backtrace.join("\n"))
    end
  end
end
