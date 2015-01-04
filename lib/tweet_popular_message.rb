require "group_me"

class TweetPopularMessage
  include GroupMe

  POPULAR_TWEET_THRESHOLD = ENV["POPULAR_TWEET_THRESHOLD"].to_i

  def self.watch_bfl(redis)
    recent_messages = UserRecentMessages.new(ENV["BFL_USER_ID"], redis)
    shit_bfl_says   = ShitBflSays.new(ENV["SBFL_SAYS_TOKEN"], ENV["SBFL_SAYS_SECRET"])
    new(shit_bfl_says).tweet_messages(recent_messages) do |message|
      recent_messages.remove message
    end
  end

  def initialize(twitter)
    @twitter = twitter
  end

  def tweet_messages(messages, &b)
    messages.each do |message_id|
      message = get_message(KRYPPIE_GROUP_ID, message_id, KRYPPIE_BOT_ACCESS_TOKEN)
      if message.fetch("favorited_by", []).count > POPULAR_TWEET_THRESHOLD
        begin
          tweet = @twitter.tweet(message["text"])
          post_as_bot(KRYPPIE_BOT_ID, tweet.url)
          yield message if block_given?
        rescue TwitterSupport::Error => e
          log(:error).message("Unable to post tweet:")
          log(:error).error(e)
        end
      end
      sleep 1.0
    end
  end
end
