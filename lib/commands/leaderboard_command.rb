require "group_me"

module Commands
  class LeaderboardCommand
    include GroupMe

    def initialize(cache, message)
      @cache = cache
      options = parse_message(message["text"])
      @type = (options[:type] || "standard").downcase
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
       "standard" => -> { Response.new(@period).respond(leaderboard) },
       "likes"    => -> { LikeResponse.new(@period, user_map).respond(leaderboard) },
       "hits"     => -> { HitResponse.new(@period).respond(leaderboard) }
      }
    end

    def user_map
      @cache.fetch(group_key, expires_in: (3600 * 3)) {
        get_group(KRYPPIE_GROUP_ID, KRYPPIE_BOT_ACCESS_TOKEN)
      }.fetch("members", []).reduce({}){ |users, member|
        users[member["user_id"]] = member["nickname"]
        users
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

        leader = messages.sort_by { |msg| -msg.fetch("favorited_by", []).count }.first
        count  = leader.fetch("favorited_by", []).count
        "\"#{leader["text"]}\", #{leader["name"]}. #{count} hearts"
      end

      private
      def empty_response
        "No leaderboard data for the #{@period}"
      end
    end

    class LikeResponse < Response
      def initialize(period, user_map)
        super period
        @user_map = user_map
      end

      def respond(messages)
        messages = Array(messages)
        return empty_response if messages.empty?

        response = "Like leaderboard for the #{@period}:\n"
        response << Array(messages)
          .flat_map { |msg| msg.fetch("favorited_by", []) }
          .reduce(Hash.new(0)) { |likes, msg| likes[msg] += 1; likes }
          .map { |user_id, likes| LikeCount.new(@user_map.fetch(user_id, "Someone"), likes) }
          .sort_by { |lc| -lc.count }
          .map { |lc| lc.to_s }.join("\n")
      end

      private
      LikeCount = Struct.new(:name, :count) do
        def to_s
          "* #{name} has given #{count} hearts"
        end
      end
    end

    class HitResponse < Response
      def respond(messages)
        messages = Array(messages)
        return empty_response if messages.empty?

        response = "Hit leaderboard for the #{@period}:\n"
        response << Array(messages).reduce(Hash.new(0)) { |likes, msg|
          likes[msg["name"]] += msg.fetch("favorited_by", []).count
          likes
        }.reduce([]) { |lines, user|
          lines << "* #{user[0]} has received #{user[1]} hearts"
        }.join("\n")
      end
    end
  end
end
