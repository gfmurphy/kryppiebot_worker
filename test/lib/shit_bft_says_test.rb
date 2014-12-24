require "test_helper"
require "shit_bfl_says"

class ShitBflSaysTest < Test::Unit::TestCase
  def setup
    @token = stub
    @secret = stub
    @bfl = ShitBflSays.new(@token, @secret)
  end

  def test_tweet
    message = "foo"
    tweet = stub
    tweeter = mock.tap { |t| t.expects(:tweet).with(message).returns(tweet) }
    @bfl.expects(:as_user).with(@token, @secret).returns(tweeter)
    assert_equal tweet, @bfl.tweet(message)
  end
end
