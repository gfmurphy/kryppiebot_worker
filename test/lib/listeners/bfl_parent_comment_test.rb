require "test_helper"

module Listeners
  class BflParentCommentTest < Test::Unit::TestCase
    def setup
      @bfl_user_id = 1
      @mock_tweeter = mock
    end
    
    def test_parent_comment_from_bfl
      text = "foo As a \npaRent i try"
      message = { "user_id" => @bfl_user_id, "text" => text }
      @mock_tweeter.expects(:tweet).with(text).once
      
      assert_nothing_raised do
        BflParentComment.new(@bfl_user_id, @mock_tweeter).tweet(message)
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
