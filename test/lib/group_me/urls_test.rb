require 'test_helper'

module GroupMe
  class UrlsTest < Test::Unit::TestCase
    def test_group_url
      assert_equal "https://api.groupme.com/v3/groups/1", Urls.group_url(1)
    end

    def test_leaderboard_url
      assert_equal "https://api.groupme.com/v3/groups/1/likes", Urls.leaderboard_url(1)
    end

    def test_message_url
      assert_equal "https://api.groupme.com/v3/groups/1/messages/2", Urls.message_url(1, 2)
    end

    def test_bot_post_url
      assert_equal "https://api.groupme.com/v3/bots/post", Urls.bot_post_url
    end
  end
end
