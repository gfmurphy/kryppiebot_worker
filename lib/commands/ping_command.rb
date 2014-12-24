require "group_me"

module Commands
  class PingCommand
    include GroupMe

    def execute
      post_as_bot(KRYPPIE_BOT_ID, "PONG!")
    end
  end
end
