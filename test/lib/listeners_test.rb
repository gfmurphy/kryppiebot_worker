require 'test_helper'

class ListenersTest < Test::Unit::TestCase
  def test_default_listerers_contains_listeners
    listeners = Listeners.default_listeners
    assert_kind_of Array, listeners
    assert_not_empty listeners
    listeners.each do |listener|
      assert_respond_to listener, :call
    end
  end
end
