module Listeners
  class BflParentComment
    def initialize(user_id, twitter)
      @user_id = user_id
      @twitter = twitter 
    end

    def tweet(message)
      text = message["text"]
      user_id = message["user_id"].to_s

      if @user_id.to_s == user_id && text.gsub(/\W+/, ' ') =~ /as a parent/mi
        @twitter.tweet(text)
      end
    end
  end
end
