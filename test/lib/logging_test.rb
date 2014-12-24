require "test_helper"

class LoggingTest < Test::Unit::TestCase
  def setup
    @old_logger = Logging.logger
  end

  def teardown
    Logging.logger = @old_logger
  end

  def test_log_message_with_default_level
    logger = mock("logger")
    logger.expects(:info).with("foo")

    Logging.logger = logger
    Logging.log.message("foo")
  end

  def test_log_message_custom_level
    logger = mock("logger")
    logger.expects(:error).with("foo")

    Logging.logger = logger
    Logging.log(:error).message("foo")
  end

  def test_log_error_with_default_level
    error = mock(message: "foo", backtrace: ['one', 'two'])
    logger = mock("logger")
    logger.expects(:info).once.with("foo")
    logger.expects(:info).once.with("one\ntwo")

    Logging.logger = logger
    Logging.log.error(error)
  end

  def test_log_error_with_custom_level
    error = mock(message: "foo", backtrace: ['one', 'two'])
    logger = mock("logger")
    logger.expects(:error).once.with("foo")
    logger.expects(:error).once.with("one\ntwo")

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

