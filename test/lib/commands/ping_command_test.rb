require "test_helper"

module Commands
  class PingCommandTest < Test::Unit::TestCase
    def test_execute
      command = PingCommand.new
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "PONG!")
      assert_nothing_raised do
        command.execute
      end
    end
  end
end
