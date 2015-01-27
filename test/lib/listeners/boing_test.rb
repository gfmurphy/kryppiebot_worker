require "test_helper"

module Listeners
  class BoingTest < Test::Unit::TestCase
    def setup
      @mock_redis = mock
    end

    def test_normal_message
      message = { "text" => "foo message"}
      boing = Boing.new(@mock_redis)
      boing.expects(:post_as_bot).never
      assert_nothing_raised do
        boing.listen(message)
      end
    end

    def test_listen_with_boing_message
      message = { "text" => "Boing"}
      boing = Boing.new(@mock_redis)
      stub_boing_response = stub(boing?: true, text: "", image: "http://example.com/img.jpg")
      Boing::BoingResponse.expects(:new).returns(stub_boing_response)
      boing.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "", "http://example.com/img.jpg")
      assert_nothing_raised do
        boing.listen(message)
      end
    end
  end

  class Boing::BoingResponseTest < Test::Unit::TestCase
    def setup
      @image_set = mock
    end

    def test_boing_with_bad_message
      boing_response = Boing::BoingResponse.new(@image_set, "foo message")
      assert !boing_response.boing?
    end

    def test_boing_with_missing_image
      boing_response = Boing::BoingResponse.new(@image_set, "boing")
      assert boing_response.boing?
    end

    def test_boing
      boing_response = Boing::BoingResponse.new(@image_set, "boing")
      assert boing_response.boing?
      assert_equal "CENSORED", boing_response.text
      assert_equal nil, boing_response.image
    end
  end
end
