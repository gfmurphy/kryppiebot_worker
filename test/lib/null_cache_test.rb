require 'test_helper'

class NullCacheTest < Test::Unit::TestCase
  def test_fetch
    test_mock = mock.tap { |m| m.expects(:boom!).returns("bar") }
    NullCache.new.fetch("foo") do
      assert_equal "bar", test_mock.boom!
    end
  end
end
