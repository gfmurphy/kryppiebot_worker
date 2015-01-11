require 'test_helper'

module Listeners
  class ThankYouTest < Test::Unit::TestCase
    def test_thank_you_match
      message = { "text" => "thanks kryppiebot", "name" => "George Murphy"}
      thanks = ThankYou.new
      thanks.expects(:post_as_bot)

      assert_nothing_raised do
        thanks.listen(message)
      end
    end

    def test_thank_you_miss
      message = { "text" => "wtf? kryppiebot", "name" => "George Murphy"}
      thanks = ThankYou.new
      thanks.expects(:post_as_bot).never

      assert_nothing_raised do
        thanks.listen(message)
      end
    end
  end
end
