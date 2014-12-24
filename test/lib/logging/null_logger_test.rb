require "test_helper"
module Logging
  class NullLoggerTest < Test::Unit::TestCase
    def test_error
      assert_nothing_raised do
        NullLogger.new.error("boom")
      end
    end

    def test_fatal
      assert_nothing_raised do
        NullLogger.new.fatal("boom")
      end
    end

    def test_warn
      assert_nothing_raised do
        NullLogger.new.warn("boom")
      end
    end

    def test_debug
      assert_nothing_raised do
        NullLogger.new.debug("boom")
      end
    end

    def test_info
      assert_nothing_raised do
        NullLogger.new.info("boom")
      end
    end
  end
end
