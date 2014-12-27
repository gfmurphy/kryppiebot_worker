class RedisCache
  def initialize(redis)
    @redis = redis
  end

  def fetch(key, options={}, &b)
    expires_in = options.fetch(:expires_in, 0)
    data = @redis.get key
    if data.nil? && block_given?
      yield.tap { |d| cache_response(key, d, expires_in)  }
    else
      data
    end
  end

  private
  def cache_response(key, data, expires=nil)
    expires = expires.to_i
    @redis.multi do
      @redis.set key, data
      @redis.expires key, expires if expires > 0
    end
  end
end
