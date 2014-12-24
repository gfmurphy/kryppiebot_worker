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

  def test_handler_ping_command
    assert_kind_of Proc, Commands.handler("text" => "!kryppiebot ping")
  end

  def test_handler_unknown_command
    assert_kind_of Commands::NullCommand, Commands.handler("text" => "!kryppiebot foo")
  end
end


