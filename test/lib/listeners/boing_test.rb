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
      mock_boing_image = mock(select_image: nil)
      Boing::BoingImage.expects(:new).with(@image_set).returns(mock_boing_image)
      boing_response = Boing::BoingResponse.new(@image_set, "boing")
      assert !boing_response.boing?
    end

    def test_boing
      mock_boing_image = mock(select_image: "http://example.com/image.jpg")
      Boing::BoingImage.expects(:new).with(@image_set).returns(mock_boing_image)
      boing_response = Boing::BoingResponse.new(@image_set, "boing")
      assert boing_response.boing?
      assert_equal "", boing_response.text
      assert_equal "http://example.com/image.jpg", boing_response.image
    end
  end

  class Boing::BoingImageTest < Test::Unit::TestCase
    def setup
      @image_set = mock
    end

    def test_select_image_with_empty_set
      @image_set.expects(:random).returns(nil)
      stub_file_store = stub
      GroupMe::FileStore.expects(:new).with(GroupMe::KRYPPIE_BOT_ID).returns(stub_file_store)
      Boing::BoingImage::IMAGES.each do |image| 
        @image_set.expects(:add).with(image, stub_file_store).returns({"url" => image})
      end
      boing_image = Boing::BoingImage.new(@image_set)
      assert_include Boing::BoingImage::IMAGES, boing_image.select_image
    end

    def test_select_image
      @image_set.expects(:random).returns("http://example.com/image.jpg")
      boing_image = Boing::BoingImage.new(@image_set)
      assert_equal "http://example.com/image.jpg", boing_image.select_image
    end
  end
end
