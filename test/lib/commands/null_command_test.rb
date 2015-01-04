require "test_helper"

module Commands
  class NullCommandTest < Test::Unit::TestCase
    def test_call_with_first_name
      command = NullCommand.new({"name" => "george"})
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't get it, george.")
      assert_nothing_raised do
        command.execute
      end
    end

    def test_call_with_first_and_last_name
      command = NullCommand.new({"name" => "george murphy"})
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't get it, george.")
      assert_nothing_raised do
        command.execute
      end
    end

    def test_call_with_nil_name
      command = NullCommand.new({})
      command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't get it.")
      assert_nothing_raised do
        command.execute
      end
    end
  end
end

