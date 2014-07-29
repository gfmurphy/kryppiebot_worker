require "test_helper"
require "logging"

class LoggingTest < Test::Unit::TestCase
  def setup
    @old_logger = Logging.logger
  end

  def teardown
    Logging.logger = @old_logger
  end

  def test_log_message_with_default_level
    logger = flexmock('logger')
    logger.should_receive(:info).with("foo")

    Logging.logger = logger
    Logging.log.message("foo")
  end

  def test_log_message_custom_level
    logger = flexmock("logger")
    logger.should_receive(:error).with("foo")

    Logging.logger = logger
    Logging.log(:error).message("foo")
  end

  def test_log_error_with_default_level
    error = flexmock(message: "foo", backtrace: ['one', 'two'])
    logger = flexmock("logger")
    logger.should_receive(:info).once.with("foo")
    logger.should_receive(:info).once.with("one\ntwo")

    Logging.logger = logger
    Logging.log.error(error)
  end

  def test_log_error_with_custom_level
    error = flexmock(message: "foo", backtrace: ['one', 'two'])
    logger = flexmock("logger")
    logger.should_receive(:error).once.with("foo")
    logger.should_receive(:error).once.with("one\ntwo")

    Logging.logger = logger
    Logging.log(:error).error(error)
  end

  def test_no_logger
    Logging.logger = nil
    assert_nothing_raised do
      Logging.log.message("foo")
    end
  end
end

class Logging::NullLoggerTest < Test::Unit::TestCase
  def test_error
    assert_nothing_raised do
      Logging::NullLogger.new.error("boom")
    end
  end

  def test_fatal
    assert_nothing_raised do
      Logging::NullLogger.new.fatal("boom")
    end
  end

  def test_warn
    assert_nothing_raised do
      Logging::NullLogger.new.warn("boom")
    end
  end

  def test_debug
    assert_nothing_raised do
      Logging::NullLogger.new.debug("boom")
    end
  end

  def test_info
    assert_nothing_raised do
      Logging::NullLogger.new.info("boom")
    end
  end
end

class Logging::LogTest < Test::Unit::TestCase
  def setup
    @logger = flexmock("logger")
  end

  def test_log_message
    @logger.should_receive(:call).with("foo").and_return("bar")
    log = Logging::Log.new(@logger)
    assert_equal "bar", log.message("foo")
  end

  def test_log_error
    error = StubError.new("foo", ["bar", "baz"])
    @logger.should_receive(:call).with(error.message)
    @logger.should_receive(:call).with(error.backtrace.join("\n")).and_return("bar")
    log = Logging::Log.new(@logger)
    assert_equal "bar", log.error(error)
  end
end

StubError = Struct.new(:message, :backtrace)
