require "group_me"

module Commands
  class LeaderboardCommand
    include GroupMe

    def initialize(cache, message)
      @cache = cache
      options = parse_message(message["text"])
      @type = (options[:type] || "top").downcase
      @period = (options[:period] || "month").downcase
    end

    def execute
      validate_command do
        post_as_bot KRYPPIE_BOT_ID, responses.fetch(@type).call
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
      Hash[[:period, :type].zip(message.split(/\s+/)[2..-1])]
    end

    def validate_command(&b)
      periods = %w(day week month)
      types = responses.keys

      if !periods.include?(@period)
        post_as_bot KRYPPIE_BOT_ID, "I don't have a report for '#{@period}'. Try #{periods.join('|')}"
      elsif !types.include?(@type)
        post_as_bot KRYPPIE_BOT_ID, "What is the '#{@type}' leaderboard? I understand #{types.join('|')}"
      else
        yield
      end
    end

    def responses
      {
       "top" => -> { Response.new(@period).respond(leaderboard) }
      }
    end

    def leaderboard
      @cache.fetch(leaderboard_key, expires_in: 3600) do
        get_leaderboard(KRYPPIE_GROUP_ID, @period, KRYPPIE_BOT_ACCESS_TOKEN)
      end      
    end

    def leaderboard_key
      "groups:#{KRYPPIE_GROUP_ID}:leaderboard:#{@period}"
    end

    def group_key
      "groups:#{KRYPPIE_GROUP_ID}"
    end

    class Response
      def initialize(period)
        @period = period
      end

      def respond(messages)
        messages = Array(messages)
        return empty_response if messages.empty?

        leaders = messages.sort_by { |msg| -msg.fetch("favorited_by", []).count }.take(5)
        leaders.reduce("Top messages for the #{@period}:\n\n") { |msg, leader|
          count  = leader.fetch("favorited_by", []).count
          msg << "*  \"#{leader["text"]}\", #{leader["name"]}. #{count} hearts\n"
        }
      end

      private
      def empty_response
        "No leaderboard data for the #{@period}"
      end
    end
  end
end
