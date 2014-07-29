require "logging"
require "group_me"

module Commands
  extend self

  COMMAND_PREFIX = /^!kryppiebot,?\s+/i
  BOT_ID = ENV["TOKEN"]

  @commands = {
    "echo" => -> (message) { EchoCommand.new(BOT_ID, message).execute }
  }

  def handler(message)
    text = message["text"].to_s
    if COMMAND_PREFIX =~ text
      fetch(text.split(/\s+/)[1].to_s.downcase) { NullCommand.new(BOT_ID) }
    else
      ->(msg) { Logging.log(:info).message(msg.inspect) }
    end
  end

  def fetch(key, &b)
    @commands.fetch(key, &b)
  end

  class EchoCommand
    def initialize(bot_id, message)
      @bot_id = bot_id
      @message = message
    end

    def execute
      name = @message["name"]
      text = @message["text"]
      GroupMe.post_as_bot(@bot_id, generate_response(name, parse_echo(text)))
    end

    private
    def generate_response(name, text)
      if text.empty?
        "#{name}, you didn't say anything."
      else
        "#{name}, you said, \"#{text}\"."
      end
    end

    def parse_echo(text)
      text.split(/\s+/)[2..-1].join(" ")
    end
  end

  class NullCommand
    def initialize(bot_id)
      @bot_id = bot_id
    end

    def call(message)
      name = message["name"].to_s.split(/\s+/).first
      GroupMe.post_as_bot(@bot_id, generate_response(name))
    end

    private
    def generate_response(name)
      "I don't get it.".tap { |resp|
        resp.gsub!('.', ", #{name}.") unless name.nil?
      }
    end
  end
end
