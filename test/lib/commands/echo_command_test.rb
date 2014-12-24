require "test_helper"

module Commands
  class EchoCommandTest < Test::Unit::TestCase
    def test_execute_blank
      message = { "name" => "george", "text" => "!kryppiebot echo" }
      command = EchoCommand.new(message)
      command.expects(:post_as_bot)
        .with(GroupMe::KRYPPIE_BOT_ID, "george, you didn't say anything.")
      assert_nothing_raised do
        command.execute
      end
    end

    def test_execute
      message = { "name" => "george", "text" => "!kryppiebot echo foo" }
      command = EchoCommand.new(message)
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "george, you said, \"foo\".")
      assert_nothing_raised do
        command.execute
      end
    end
  end
end
