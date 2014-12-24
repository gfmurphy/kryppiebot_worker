require "redis"

class UserRecentMessages
  include Enumerable

  def initialize(user_id, redis, options={})
    @user_id = user_id
    @redis = redis
    @max_messages = options.fetch(:max_messages, 25)
  end

  def add(message)
    if message["user_id"].to_i == @user_id.to_i
      @redis.multi do
        @redis.lpush list_key, message["id"]
        @redis.ltrim list_key, 0, @max_messages
      end
    end
  end

  def each(&block)
    @redis.lrange(list_key, 0, -1).dup.each(&block)
  end

  def remove(message)
    @redis.lrem list_key, 0, message["id"]
  end

  private
  def list_key
    "users:#{@user_id}:recent_messages"
  end
end
