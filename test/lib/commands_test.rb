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

  def test_handler_echo_command
    stub_message = { "text" => "!kryppiebot echo boom!" }
    Commands::EchoCommand.expects(:new).with(stub_message).returns(mock_command)
    command = Commands.handler(stub_message)
    assert_respond_to command, :call
    assert_nothing_raised do
      command.call
    end
  end

  def test_handler_ping_command
    stub_message = { "text" => "!kryppiebot ping" }
    Commands::PingCommand.expects(:new).returns(mock_command)
    command = Commands.handler(stub_message)
    assert_respond_to command, :call
    assert_nothing_raised do
      command.call
    end
  end

  def test_handler_leaderboard_command
    stub_redis_cache = stub
    stub_message = { "text" => '!kryppiebot leaderboard' }
    Commands.expects(:redis_cache).returns(stub_redis_cache)
    Commands::LeaderboardCommand.expects(:new).with(stub_redis_cache, stub_message)
      .returns(mock_command)
    command = Commands.handler(stub_message)
    assert_respond_to command, :call
    assert_nothing_raised do
      command.call
    end
  end

  def test_handler_help_command
    stub_message = { "text" => "!kryppiebot help" }
    command = Commands.handler(stub_message)
    assert_respond_to command, :call
    assert_nothing_raised do
      command.call
    end
  end

  def test_handler_unknown_command
    stub_message = { "text" => "!kryppiebot foo" }
    Commands::NullCommand.expects(:new).with(stub_message).returns(mock_command)
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


