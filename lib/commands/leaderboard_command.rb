require "group_me"

module Commands
  class LeaderboardCommand
    include GroupMe

    def initialize(message)
      options = parse_message(message["text"])
      @period = (options[:period] || "month").downcase
    end

    def execute
      validate_command do
        post_as_bot KRYPPIE_BOT_ID, Response.new(@period).respond(leaderboard)
      end
    end

    private
    # Internal: Parses a groupme message and extracts the leaderboard type and period.
    #
    # Examples: parse_message('!kryppiebot leaderboard month hits') 
    #             => { period: 'month', type: 'hits' }
    #
    # Returns a Hash with type and period keys.
    def parse_message(message)
      Hash[[:period].zip(message.split(/\s+/)[2..-1])]
    end

    def validate_command(&b)
      periods = %w(day week month)
      if !periods.include?(@period)
        post_as_bot KRYPPIE_BOT_ID, "I don't have a report for '#{@period}'. Try #{periods.join('|')}"
      else
        yield
      end
    end

    def leaderboard
      get_leaderboard(KRYPPIE_GROUP_ID, @period, KRYPPIE_BOT_ACCESS_TOKEN)
    end

    def leaderboard_key
      "groups:#{KRYPPIE_GROUP_ID}:leaderboard:#{@period}"
    end

    class Response
      def initialize(period)
        @period = period
      end

      def respond(messages)
        messages = Array(messages)
        return "No leaderboard data for the #{@period}" if messages.empty?
        leaders = messages.take(5)
        leaders.reduce([]) { |a, l|
          count = l.fetch("favorited_by", []).count
          a << [l["name"], l["text"], "#{count} hearts"]
        }.to_text_table.to_s
      end
    end
  end
end
