require "test_helper"
require "commands"

class CommandsTest < Test::Unit::TestCase
  def test_handler_no_command
    assert Commands.handler("text" => "no command").respond_to?(:call)
  end

  def test_handler_echo_command
    assert_respond_to Commands.handler("text" => "!kryppiebot echo boom!"), :call
  end

  def test_handler_ping_command
    assert_respond_to Commands.handler("text" => "!kryppiebot ping"), :call
  end

  def test_handler_leaderboard_command
    assert_respond_to Commands.handler("text" => '!kryppiebot leaderboard'), :call
  end

  def test_handler_unknown_command
    assert_respond_to Commands.handler("text" => "!kryppiebot foo"), :call
  end
end


