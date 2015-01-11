require 'test_helper'

module Listeners
  class CongratsTest < Test::Unit::TestCase
    def setup
      @mock_redis = mock
      @mock_image_set = mock
      ImageSet.expects(:new).with(ImageSet::CONGRATS, @mock_redis).returns(@mock_image_set)
    end

    def test_listen
      stub_image_url = "http://i.groupme.com/image.jpeg"
      message = {"text" => "congrats, buddy!"}
      @mock_image_set.expects(:random).returns(stub_image_url)
      @mock_redis.expects(:get).with("congrats:responses:Buddy").returns(nil)
      @mock_redis.expects(:multi).yields
      @mock_redis.expects(:set).with("congrats:responses:Buddy", "1")
      @mock_redis.expects(:expires).with("congrats:responses:Buddy", 3600)
      congrats = Congrats.new(@mock_redis)
      congrats.expects(:post_as_bot)

      assert_nothing_raised do
        congrats.listen(message)
      end
    end

    def test_listen_with_recent_message
      message = {"text" => "congrats, buddy!"}
      @mock_image_set.expects(:random).never
      @mock_redis.expects(:get).with("congrats:responses:Buddy").returns("1")
      @mock_redis.expects(:multi).never
      @mock_redis.expects(:set).never
      @mock_redis.expects(:expires).never
      congrats = Congrats.new(@mock_redis)
      congrats.expects(:post_as_bot).never

      assert_nothing_raised do
        congrats.listen(message)
      end
    end
  end

  class CongratsMessage < Test::Unit::TestCase
    def test_response
      assert_kind_of Congrats::CongratsResponse, Congrats::CongratsMessage.new("foo").response
    end

    def test_parse_no_congrats
      assert_equal [], Congrats::CongratsMessage.new("what a jerk, flem").parse_message      
    end

    def test_parse_simple_congrats
      message = Congrats::CongratsMessage.new("mazel tov, flem!").parse_message
      assert_include Congrats::CongratsMessage.possible_responses, message[0]
      assert_equal "Flem", message[1]
    end

    def test_parse_simple_congrats_with_no_name
      message = Congrats::CongratsMessage.new("congrats!").parse_message
      assert_include Congrats::CongratsMessage.possible_responses, message[0]
      assert_equal nil, message[1]
    end

    def test_parse_simple_congrats_name_with_no_comma
      message = Congrats::CongratsMessage.new("gratz flem").parse_message
      assert_include Congrats::CongratsMessage.possible_responses, message[0]
      assert_equal nil, message[1]
    end

    def test_parse_congrats_in_middle_of_message
      message = Congrats::CongratsMessage.new("that's great news. kudos, buddy! i can't believe it").parse_message
      assert_include Congrats::CongratsMessage.possible_responses, message[0]
      assert_equal "Buddy", message[1]
    end

    def test_parse_congrats_in_end_of_message
      message = Congrats::CongratsMessage.new("that's great news. cheers, flem").parse_message
      assert_include Congrats::CongratsMessage.possible_responses, message[0]
      assert_equal "Flem", message[1]
    end
  end

  class CongratsResponseTest < Test::Unit::TestCase
    def test_nil_response
      response = Congrats::CongratsResponse.new(nil)
      assert_equal nil, response.name
      assert_empty response.text
      assert !response.congrats?
    end

    def test_response
      response = Congrats::CongratsResponse.new("mazel", "foo")
      assert_equal "mazel, foo!", response.text
      assert response.congrats?
    end
  end
end
