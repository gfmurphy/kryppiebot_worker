module Logging
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
