require 'test_helper'
require 'redis_cache'

class RedisCacheTest < Test::Unit::TestCase
  class MockRedis
    def multi(&b)
      yield if block_given?
    end
  end

  def setup
    @redis = MockRedis.new
    @key = 'foo'
  end

  def test_cache_hit
    @redis.expects(:get).with(@key).returns(Marshal.dump("bar"))
    @redis.expects(:set).never
    @redis.expects(:expires).never
    assert_equal "bar", RedisCache.new(@redis).fetch(@key, expires_in: 1) { "bar" }
  end

  def test_cache_miss_with_expiration
    @redis.expects(:get).with(@key).returns(nil)
    @redis.expects(:set).with(@key, Marshal.dump("bar"))
    @redis.expects(:expires).with(@key, 1)
    assert_equal "bar", RedisCache.new(@redis).fetch(@key, expires_in: 1) { "bar" }
  end
  
  def test_cache_miss_without_expiration
    @redis.expects(:get).with(@key).returns(nil)
    @redis.expects(:set).with(@key, Marshal.dump("bar"))
    @redis.expects(:expires).never
    assert_equal "bar", RedisCache.new(@redis).fetch(@key) { "bar" }
  end
end
