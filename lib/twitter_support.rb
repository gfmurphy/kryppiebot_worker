module TwitterSupport
  extend self

  CONSUMER_KEY = ENV["TWITTER_CONSUMER_KEY"]
  CONSUMER_SECRET = ENV["TWITTER_CONSUMER_SECRET"]

  Error = Class.new(StandardError)

  def as_user(token, secret)
    User.new(token, secret)
  end
  
  private
  class User
    def initialize(token, secret)
      @token = token
      @secret = secret
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = CONSUMER_KEY
        config.consumer_secret     = CONSUMER_SECRET
        config.access_token        = @token
        config.access_token_secret = @secret
      end
    end

    def tweet(message)
      @client.update message
    rescue => e
      fail Error.new(e.message).tap { |error| error.set_backtrace(e.backtrace) }
    end
  end
end
