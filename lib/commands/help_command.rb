module Commands
  class HelpCommand
    include GroupMe

    def execute
      post_as_bot(KRYPPIE_BOT_ID, message)
    end

    private
    def message
      <<-MSG
The most commonly used kryppiebot commands are:

* !kryppiebot ping - bot responds with PONG!
* !kryppiebot echo [text] - bot echos [text] in response
* !kryppiebot leaderboard [month|week|day] - top 5 messages for period
* !kryppiebot help - this message

      MSG
    end
  end
end
