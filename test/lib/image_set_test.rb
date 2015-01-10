require 'test_helper'
require "image_set"

class ImageSetTest < Test::Unit::TestCase
  def setup
    @stub_name = "foo"
    @mock_redis = mock
  end

  def test_add
    stub_files = mock.tap { |m| m.expects(:put).with("foo").returns({"url" => "bar"}) }
    @mock_redis.expects(:multi).yields
    @mock_redis.expects(:sadd).with("#{@stub_name}", Digest::MD5.hexdigest("foo"))
    @mock_redis.expects(:hmset).with("#{@stub_name}:images", Digest::MD5.hexdigest("foo"), "bar")
    set = ImageSet.new(@stub_name, @mock_redis)
    set.expects(:member?).with("foo").returns(false)
    assert_equal nil, set.add("foo", stub_files)
  end

  def test_add_with_empty_image
    stub_files = mock.tap { |m| m.expects(:put).with("foo").returns({}) }
    @mock_redis.expects(:multi).never
    @mock_redis.expects(:sadd).never
    @mock_redis.expects(:hmset).never
    set = ImageSet.new(@stub_name, @mock_redis)
    set.expects(:member?).with("foo").returns(false)
    assert_equal nil, set.add("foo", stub_files)
  end

  def test_add_already_member
    @mock_redis.expects(:multi).never
    @mock_redis.expects(:sadd).never
    @mock_redis.expects(:hmset).never
    set = ImageSet.new(@stub_name, @mock_redis)
    set.expects(:member?).with("foo").returns(true)
    assert set.add("foo", stub)
  end

  def test_random
    @mock_redis.expects(:srandmember).returns(1)
    @mock_redis.expects(:hget).with("#{@stub_name}:images", 1).returns("bar")
    assert_equal "bar", ImageSet.new(@stub_name, @mock_redis).random
  end

  def test_member?
    @mock_redis.expects(:sismember).with(Digest::MD5.hexdigest("bar")).returns(true)
    assert ImageSet.new(@stub_name, @mock_redis).member?("bar")
  end
end
