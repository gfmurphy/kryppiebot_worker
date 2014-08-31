require "test_helper"
require "twitter_support"

class TwitterSupportTest < Test::Unit::TestCase
  def setup
    ENV["TWITTER_CONSUMER_KEY"] = "foo"
    ENV["TWITTER_CONSUMER_SECRET"] = "bar"
  end

  def teardown
    ENV["TWITTER_CONSUMER_KEY"] = nil
    ENV["TWITTER_CONSUMER_SECRET"] = nil
  end

  def test_as_user
    assert_kind_of TwitterSupport::User, TwitterSupport.as_user("token", "secret")
  end
end

class TwitterSupport::UserTest < Test::Unit::TestCase
  def setup
    @client = mock
    Twitter::REST::Client.expects(:new).returns(@client)
  end

  def test_tweet
    message = stub
    tweet = stub
    @client.expects(:update).with(message).returns(tweet)
    assert_equal tweet, TwitterSupport::User.new("foo", "bar").tweet(message)
  end

  def test_tweet_error
    message = stub
    @client.expects(:update).with(message).raises("boom")
    assert_raises(TwitterSupport::Error, "boom") do
      TwitterSupport::User.new("foo", "bar").tweet(message)
    end
  end
end
