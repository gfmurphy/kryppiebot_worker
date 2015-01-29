require "test_helper"
require "commands"

class CommandsTest < Test::Unit::TestCase
  def test_handler_no_command
    stub_message = { "text" => "no command"}
    mock_listener = mock.tap { |m| m.expects(:call).with(stub_message) }
    Listeners.expects(:default_listeners).returns([mock_listener])
    command = Commands.handler(stub_message)

    assert_respond_to command, :call
    assert_nothing_raised do
      command.call
    end
  end

  private
  def mock_command
    mock(execute: true)
  end
end


