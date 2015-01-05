require 'test_helper'

module Commands
  class HelpCommandTest < Test::Unit::TestCase
    def test_execute
      command = HelpCommand.new
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, help_message)
      assert_nothing_raised do
        command.execute
      end
    end

    private
    def help_message
      <<-MSG
The most commonly used kryppiebot commands are:

* !kryppiebot ping - bot responds with PONG!
* !kryppiebot echo [text] - bot echos [text] in response
* !kryppiebot leaderboard [month|week|day] - top 5 messages for period
* !kryppiebot help - this message

      MSG
    end
  end
end
