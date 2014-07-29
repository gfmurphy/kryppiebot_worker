require "logging"
require "group_me"

module Commands
  extend Logging
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
      -> { log(:info).message(message.inspect) }
    end
  end

  def fetch(key, &b)
    @commands.fetch(key, &b)
  end

  class EchoCommand
    include GroupMe

    def initialize(message)
      @message = message
    end

    def execute
      name = @message["name"]
      text = @message["text"]
      post_as_bot(generate_response(name, parse_echo(text)))
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
    include GroupMe

    def call(message)
      name = message["name"].to_s.split(/\s+/).first
      post_as_bot(generate_response(name))
    end

    private
    def generate_response(name)
      "I don't get it.".tap { |resp|
        resp.gsub!('.', ", #{name}.") unless name.nil?
      }
    end
  end
end
