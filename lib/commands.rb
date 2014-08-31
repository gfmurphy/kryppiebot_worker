require "commands/echo_command"
require "commands/null_command"
require "listeners"
require "group_me"

module Commands
  extend self

  COMMAND_PREFIX = /^!kryppiebot,?\s+/i

  @commands = {
    "echo" => -> (message) { EchoCommand.new(message).execute }
  }

  def handler(message)
    text = message["text"].to_s
    if COMMAND_PREFIX =~ text
      fetch(text.split(/\s+/)[1].to_s.downcase) { NullCommand.new }
    else
      ->(msg) {
        Listeners.new(Listeners.default_listeners).each do |listener|
          listener.call(msg)
        end
      }
    end
  end

  def fetch(key, &b)
    @commands.fetch(key, &b)
  end
end
