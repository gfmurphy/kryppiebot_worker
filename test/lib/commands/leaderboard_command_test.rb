require 'test_helper'

module Commands
  class LeaderboardCommandTest < Test::Unit::TestCase
    class StubCache
      def fetch(key, *args, &b)
        yield if block_given?
      end
    end

    def setup
      @messages = [
        {"name" => "foo bar", "favorited_by" => ["123", "2345", "4053"], "text" => "foo"},
      ]
      @group_info = {
        "members" => [
          { "user_id" => "123", "nickname" => "Foo" }, 
          { "user_id" => "2345", "nickname" => "Bar" },
          { "user_id" => "4053", "nickname" => "Baz" }
        ]
      }
    end

    def test_standard_month_leaderboard
      command = LeaderboardCommand.new(StubCache.new, {"text" => "!kryppiebot leaderboard"})
      command.expects(:get_leaderboard)
        .with(GroupMe::KRYPPIE_BOT_ID, "month", GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
        .returns(@messages)
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "\"foo\", foo bar. 3 hearts")
      assert_nothing_raised do
        command.execute
      end
    end

    def test_hits_day_leaderboard
      command = LeaderboardCommand.new(StubCache.new, {"text" => "!kryppiebot leaderboard day hits"})
      command.expects(:get_leaderboard)
        .with(GroupMe::KRYPPIE_BOT_ID, "day", GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
        .returns(@messages)
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "Hit leaderboard for the day:\n* foo bar has received 3 hearts")
      assert_nothing_raised do
        command.execute
      end
    end

    def test_likes_week_leaderboard
      command = LeaderboardCommand.new(StubCache.new, {"text" => "!kryppiebot leaderboard week likes"})
      command.expects(:get_leaderboard)
        .with(GroupMe::KRYPPIE_GROUP_ID, "week", GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
        .returns(@messages)
      command.expects(:get_group).with(GroupMe::KRYPPIE_GROUP_ID, GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
        .returns(@group_info)
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "Like leaderboard for the week:\n* Foo has given 1 hearts\n* Bar has given 1 hearts\n* Baz has given 1 hearts")
      assert_nothing_raised do
        command.execute
      end
    end

    def test_invalid_period
      command = LeaderboardCommand.new(StubCache.new, {"text" => "!kryppiebot leaderboard year"})
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't have a report for 'year'. Try day|week|month")
      assert_nothing_raised do
        command.execute
      end
    end

    def test_invalid_type
      command = LeaderboardCommand.new(StubCache.new,  {"text" => "!kryppiebot leaderboard month foo"})
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "What is the 'foo' leaderboard? I understand standard|likes|hits")
      assert_nothing_raised do
        command.execute
      end
    end
  end

  class ResponseTest < Test::Unit::TestCase
    def setup
      @period = "month"
      @messages = [
        {"name" => "foo bar", "favorited_by" => ["123", "2345", "4053"], "text" => "foo"},
        {"name" => "baz bar", "favorited_by" => ["3849", "3950"], "text" => "bar"}
      ]
      @response = LeaderboardCommand::Response.new(@period)
    end

    def test_message_format
      assert_equal "\"foo\", foo bar. 3 hearts", @response.respond(@messages)
    end

    def test_empty_messages
      assert_equal "No leaderboard data for the #{@period}", @response.respond(nil)
    end
  end

  class LikeResponseTest < Test::Unit::TestCase
    def setup
      @period = "month"
      @messages = [
        {"name" => "foo bar", "favorited_by" => ["123", "2345", "3849"]},
        {"name" => "baz bar", "favorited_by" => ["3849"]},
        {"name" => "foo bar", "favorited_by" => ["123", "3849"]}
      ]
      @user_map = {
        "123" => "User One",
        "3849" => "User Two",
        "3950" => "User Three"
      }
      @response = LeaderboardCommand::LikeResponse.new(@period, @user_map)
    end

    def test_message_format
      message = "Like leaderboard for the month:\n* User Two has given 3 hearts\n* User One has given 2 hearts\n* Someone has given 1 hearts"
      assert_equal message, @response.respond(@messages)
    end

    def test_empty_messages
      assert_equal "No leaderboard data for the #{@period}", @response.respond(nil)
    end
  end

  class HitResponseTest < Test::Unit::TestCase
    def setup
      @period = "month"
      @messages = [
        {"name" => "foo bar", "favorited_by" => ["123", "2345", "4053"]},
        {"name" => "baz bar", "favorited_by" => ["3849", "3950"]},
        {"name" => "foo bar", "favorited_by" => ["123", "8495"]}
      ]
      @response = LeaderboardCommand::HitResponse.new(@period)
    end

    def test_message_format
      message = "Hit leaderboard for the month:\n* foo bar has received 5 hearts\n* baz bar has received 2 hearts"
      assert_equal message, @response.respond(@messages)
    end

    def test_empty_messages
      assert_equal "No leaderboard data for the #{@period}", @response.respond(nil)
    end
  end
end



