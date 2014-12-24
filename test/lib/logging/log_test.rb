require "test_helper"
module Logging
  class Logging::LogTest < Test::Unit::TestCase
    StubError = Struct.new(:message, :backtrace)

    def setup
      @logger = mock("logger")
    end

    def test_log_message
      @logger.expects(:call).with("foo").returns("bar")
      log = Logging::Log.new(@logger)
      assert_equal "bar", log.message("foo")
    end

    def test_log_error
      error = StubError.new("foo", ["bar", "baz"])
      @logger.expects(:call).with(error.message)
      @logger.expects(:call).with(error.backtrace.join("\n")).returns("bar")
      log = Logging::Log.new(@logger)
      assert_equal "bar", log.error(error)
    end
  end
end
