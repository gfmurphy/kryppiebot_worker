require "test_helper"
require "tweet_popular_message"

class TweetPopularMessageTest < Test::Unit::TestCase
  def setup
    @twitter = mock
    @tweet_popular = TweetPopularMessage.new(@twitter)
  end

  def test_tweet_unpopular_messages
    messages = [1]
    message_1 = {"favorited_by" =>[]} 
    @tweet_popular.expects(:get_message)
      .with(GroupMe::KRYPPIE_GROUP_ID, 1, GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
      .returns(message_1)
    @twitter.expects(:tweet).never
    @tweet_popular.expects(:post_as_bot).never
    assert_nothing_raised do
      @tweet_popular.tweet_messages(messages)
    end
  end

  def test_tweet_popular_messages
    messages = [1]
    message_1 = {
      "text" => "my popular message",
      "favorited_by" =>[stub] * (TweetPopularMessage::POPULAR_TWEET_THRESHOLD + 1) 
    }
    tweet = mock(url: "http://example.com")
    @tweet_popular.expects(:get_message)
      .with(GroupMe::KRYPPIE_GROUP_ID, 1, GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
      .returns(message_1)
    @twitter.expects(:tweet).with(message_1["text"]).returns(tweet)
    @tweet_popular.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "http://example.com")
    @tweet_popular.tweet_messages(messages) do |message| 
      assert_equal message_1, message
    end
  end

  def test_tweet_error
    messages = [1]
    message_1 = {
      "text" => "my popular message",
      "favorited_by" =>[stub] * (TweetPopularMessage::POPULAR_TWEET_THRESHOLD + 1) 
    }
    @tweet_popular.expects(:get_message)
      .with(GroupMe::KRYPPIE_GROUP_ID, 1, GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
      .returns(message_1)
    @twitter.expects(:tweet).with(message_1["text"]).raises(TwitterSupport::Error, "boom")
    @tweet_popular.expects(:post_as_bot).never
    assert_nothing_raised do
      @tweet_popular.tweet_messages(messages)
    end
  end
end
