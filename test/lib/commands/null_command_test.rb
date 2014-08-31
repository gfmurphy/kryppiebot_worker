require "test_helper"

module Commands
  class NullCommandTest < Test::Unit::TestCase
    def setup
      @command = NullCommand.new
    end

    def test_call_with_first_name
      @command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't get it, george.")
      assert_nothing_raised do
        @command.call({"name" => "george"})
      end
    end

    def test_call_with_first_and_last_name
      @command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't get it, george.")
      assert_nothing_raised do
        @command.call({"name" => "george murphy"})
      end
    end

    def test_call_with_nil_name
      @command.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "I don't get it.")
      assert_nothing_raised do
        @command.call({})
      end
    end
  end
end

