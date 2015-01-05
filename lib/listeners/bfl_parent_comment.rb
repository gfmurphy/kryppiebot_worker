module Listeners
  class BflParentComment
    include GroupMe

    def initialize(user_id, twitter)
      @user_id = user_id
      @twitter = twitter 
    end

    def tweet(message)
      text = message["text"]
      user_id = message["user_id"].to_s

      if @user_id.to_s == user_id && text.gsub(/\W+/, ' ') =~ /as a parent/mi
        tweet = @twitter.tweet(text)
        post_as_bot(KRYPPIE_BOT_ID, tweet.url)
      end
    rescue TwitterSupport::Error => e
      log(:error).error(e)
      post_as_bot(KRYPPIE_BOT_ID, "This should be tweeted, '#{text}', but I couldn't do it.")
    end
  end
end
