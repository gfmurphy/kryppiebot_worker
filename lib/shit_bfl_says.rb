require "twitter_support"

class ShitBflSays
  include TwitterSupport

  def initialize(token, secret)
    @token = token
    @secret = secret
  end

  def tweet(message)
    as_user(@token, @secret).tweet(message)
  end
end
