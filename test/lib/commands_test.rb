require "test_helper"
require "commands"

class CommandsTest < Test::Unit::TestCase
  def test_fetch_echo_command
    assert_kind_of Proc, Commands.fetch("echo")
  end

  def test_fetch_unknown
    assert_equal "boo", Commands.fetch("unknown") { "boo" }
  end

  def test_handler_no_command
    assert Commands.handler("text" => "no command").respond_to?(:call)
  end

  def test_handler_echo_command
    assert_kind_of Proc, Commands.handler("text" => "!kryppiebot echo boom!")
  end

  def test_handler_unknown_command
    assert_kind_of Commands::NullCommand, Commands.handler("text" => "!kryppiebot foo")
  end
end

class EchoCommandTest < Test::Unit::TestCase
  def test_execute_blank
    message = { "name" => "george", "text" => "!kryppiebot echo" }
    command = flexmock(Commands::EchoCommand.new(message), :strict)
    command.should_receive(:post_as_bot).with("george, you didn't say anything.")
    command.execute
  end

  def test_execute
    message = { "name" => "george", "text" => "!kryppiebot echo foo" }
    command = flexmock(Commands::EchoCommand.new(message), :strict)
    command.should_receive(:post_as_bot).with("george, you said, \"foo\".")
    
    command.execute
  end
end

class NullCommandTest < Test::Unit::TestCase
  def test_call_with_first_name
    command = flexmock(Commands::NullCommand.new, :strict)
    command.should_receive(:post_as_bot).with("I don't get it, george.")

    command.call({"name" => "george"})
  end

  def test_call_with_first_and_last_name
    command = flexmock(Commands::NullCommand.new, :strict)
    command.should_receive(:post_as_bot).with("I don't get it, george.")

    command.call({"name" => "george murphy"})
  end

  def test_call_with_nil_name
    command = flexmock(Commands::NullCommand.new, :strict)
    command.should_receive(:post_as_bot).with("I don't get it.")

    command.call({})
  end
end
