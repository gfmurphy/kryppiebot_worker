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

    def test_top_month_leaderboard
      command = LeaderboardCommand.new(StubCache.new, {"text" => "!kryppiebot leaderboard"})
      command.expects(:get_leaderboard)
        .with(GroupMe::KRYPPIE_BOT_ID, "month", GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
        .returns(@messages)
      expected = "Top messages for the month:\n\n*  \"foo\", foo bar. 3 hearts\n"
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, expected)
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
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "What is the 'foo' leaderboard? I understand top")
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
      expected = "Top messages for the month:\n\n*  \"foo\", foo bar. 3 hearts\n*  \"bar\", baz bar. 2 hearts\n"
      assert_equal expected, @response.respond(@messages)
    end

    def test_empty_messages
      assert_equal "No leaderboard data for the #{@period}", @response.respond(nil)
    end
  end
end



