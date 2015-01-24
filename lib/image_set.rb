require "digest/md5"

class ImageSet
  CONGRATS = "congrats"
  BOING = "boing"

  def initialize(name, redis, opts={})
    @set = "#{name}"
    @images = "#{name}:images"
    @redis = redis
    @expires = opts[:expires_in]
  end

  def add(url, files)
    return true if member?(url)
    key = hash(url)
    files.put(url).tap { |img|
      @redis.multi do
        @redis.sadd(@set, key)
        @redis.hmset(@images, key, img["url"])
        expire_set!
      end unless img.empty?
    }
  end

  def random
    @redis.hget(@images, @redis.srandmember(@set))
  end

  def member?(url)
    @redis.sismember(@set, hash(url))
  end

  private
  def expire_set!
    if @expires
      @redis.expires @set, @expires
      @redis.expires @images, @expires
    end
  end

  def hash(url)
    Digest::MD5.hexdigest(url)
  end
end
