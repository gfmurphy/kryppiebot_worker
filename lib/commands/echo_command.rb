require "group_me"

module Commands
  class EchoCommand
    include GroupMe

    def initialize(message)
      @message = message
    end

    def execute
      name = @message["name"]
      text = @message["text"]
      post_as_bot(KRYPPIE_BOT_ID, generate_response(name, parse_echo(text)))
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
end
