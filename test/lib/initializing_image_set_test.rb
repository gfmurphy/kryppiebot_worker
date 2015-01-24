require "test_helper"

class InitializingImageSetTest < Test::Unit::TestCase
  def setup
    @image_set = mock
    @images = ["http://example.com/image.jpg"]
  end

  def test_random_with_empty_set
    @image_set.expects(:random).returns(nil)
    stub_file_store = stub
    GroupMe::FileStore.expects(:new).with(GroupMe::KRYPPIE_BOT_ID).returns(stub_file_store)
    @images.each do |image| 
        @image_set.expects(:add).with(image, stub_file_store).returns({"url" => image})
      end
    image_set = InitializingImageSet.new(@image_set, @images)
    assert_include @images, image_set.random
  end

  def test_random
    @image_set.expects(:random).returns("http://example.com/image.jpg")
    image_set = InitializingImageSet.new(@image_set, @images)
    assert_equal "http://example.com/image.jpg", image_set.random
  end
end
