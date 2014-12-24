require "test_helper"

class UserRecentMessagesTest < Test::Unit::TestCase
  class MockRedis
    def multi(&b)
      yield if block_given?
    end
  end

  def setup
    @user_id = "12345"
    @message = {"user_id" => @user_id, "id" => "123456"}
    @max_messages = 10
  end

  def test_add_message_with_matching_user_id
    redis = MockRedis.new
    redis.expects(:lpush).with("users:#{@user_id}:recent_messages", "123456")
    redis.expects(:ltrim).with("users:#{@user_id}:recent_messages", 0, @max_messages)
    assert_nothing_raised do
      UserRecentMessages.new(@user_id, redis, max_messages: @max_messages).add @message
    end
  end

  def test_add_message_without_user_id
    redis = MockRedis.new
    redis.expects(:lpush).never
    redis.expects(:ltrim).never
    @message["user_id"] = "948491"
    assert_nothing_raised do
      UserRecentMessages.new(@user_id, redis).add @message
    end
  end

  def test_each
    messages = [mock(id: 1), mock(id: 2)]
    redis = mock("redis")
    redis.expects(:lrange).with("users:#{@user_id}:recent_messages", 0, -1).returns(messages)
    UserRecentMessages.new(@user_id, redis).each do |msg|
      assert msg.id
    end
  end

  def test_remove
    message = {"id" => "1234"}
    redis = mock("redis")
    redis.expects(:lrem).with("users:#{@user_id}:recent_messages", 0, "1234")
    assert_nothing_raised do
      UserRecentMessages.new(@user_id, redis).remove message
    end
  end
end
