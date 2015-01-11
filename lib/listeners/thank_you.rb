module Listeners
  class ThankYou
    include GroupMe

    def listen(message)
      text = message["text"].to_s
      name = message["name"].to_s
      post_as_bot(KRYPPIE_BOT_ID, select_response(name)) if text =~ thanks_pattern
    end

    private
    def thanks_pattern
      /(thanks|thank you|gracias),?\s+kryppiebot/i
    end

    def select_response(name)
      resp = ["You bet", "Anytime", "No problem", "You're welcome", "Sure thing"].sample
      [resp, name.split(/\s+/).first].join(", ")
    end
  end
end
