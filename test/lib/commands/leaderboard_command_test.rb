require 'test_helper'

module Commands
  class LeaderboardCommandTest < Test::Unit::TestCase
    def setup
      @messages = [
        {"name" => "foo", "favorited_by" => ["123", "2345", "4053"], "text" => "foo bar"},
      ]
    end

    def test_top_month_leaderboard
      command = LeaderboardCommand.new("text" => "!kryppiebot leaderboard")
      command.expects(:get_leaderboard)
        .with(GroupMe::KRYPPIE_BOT_ID, "month", GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
        .returns(@messages)
      command.stubs(:post_as_bot)
      assert_nothing_raised do
        command.execute
      end
    end

    def test_invalid_period
      command = LeaderboardCommand.new("text" => "!kryppiebot leaderboard year")
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't have a report for 'year'. Try day|week|month")
      assert_nothing_raised do
        command.execute
      end
    end
  end

  class ResponseTest < Test::Unit::TestCase
    def setup
      @period = "month"
      @messages = [
        {"name" => "foo", "favorited_by" => ["123", "2345", "4053"], "text" => "foo bar"},
        {"name" => "bar", "favorited_by" => ["3849", "3950"], "text" => "baz bar"}
      ]
      @response = LeaderboardCommand::Response.new(@period)
    end

    def test_message_format
      assert_match /foo.+3/, @response.respond(@messages)
    end

    def test_empty_messages
      assert_equal "No leaderboard data for the #{@period}", @response.respond(nil)
    end
  end
end



