require "test_helper"

module Listeners
  class BflParentCommentTest < Test::Unit::TestCase
    def setup
      @bfl_user_id = 1
      @mock_tweeter = mock
    end
    
    def test_parent_comment_from_bfl
      stub_text = "foo As a \npaRent i try"
      stub_message = { "user_id" => @bfl_user_id, "text" => stub_text }
      stub_url = "http://twitter.com/tweets/1234"
      mock_tweet = mock(url: stub_url)
      @mock_tweeter.expects(:tweet).with(stub_text).once.returns(mock_tweet)
      comment_listener = BflParentComment.new(@bfl_user_id, @mock_tweeter)
      comment_listener.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, stub_url)

      assert_nothing_raised do
        comment_listener.tweet(stub_message)
      end
    end

    def test_twitter_error
      stub_message = { "user_id" => @bfl_user_id, "text" => "as a parent" }
      error = TwitterSupport::Error.new("boom")
      response_message = "This should be tweeted, 'as a parent', but I couldn't do it."
      @mock_tweeter.expects(:tweet).with("as a parent").once.raises(error)
      comment_listener = BflParentComment.new(@bfl_user_id, @mock_tweeter)
      comment_listener.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, response_message)

      assert_nothing_raised do
        comment_listener.tweet(stub_message)
      end
    end

    def test_parent_comment_from_other_user
      message = { "user_id" => 2, "text" => "as a parent i try"}
      @mock_tweeter.expects(:tweet).never

      assert_nothing_raised do
        BflParentComment.new(@bfl_user_id, @mock_tweeter).tweet(message)
      end
    end

    def test_no_parent_comment
      message = { "user_id" => @bfl_user_id, "text" => "normal tweet" }
      @mock_tweeter.expects(:tweet).never

      assert_nothing_raised do
        BflParentComment.new(@bfl_user_id, @mock_tweeter).tweet(message)
      end
    end
  end
end
