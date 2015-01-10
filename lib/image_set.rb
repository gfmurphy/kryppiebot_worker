require "digest/md5"

class ImageSet
  def initialize(name, redis)
    @set = "#{name}"
    @images = "#{name}:images"
    @redis = redis
  end

  def add(url, files)
    return true if member?(url)
    key = hash(url)
    image = files.put(url)
    @redis.multi do
        @redis.sadd(@set, key)
        @redis.hmset(@images, key, image["url"])
    end unless image.empty?
  end

  def random
    @redis.hget(@images, @redis.srandmember)
  end

  def member?(url)
    @redis.sismember(hash(url))
  end

  private
  def hash(url)
    Digest::MD5.hexdigest(url)
  end
end
