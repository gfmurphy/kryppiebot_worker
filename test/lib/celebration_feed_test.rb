require 'test_helper'
require "celebration_feed"

module CelebrationFeed
  class CelebrationFeedTest < Test::Unit::TestCase
    def test_add_image_urls      
      rss_url = stub
      stub_image = stub
      stub_files = stub
      mock_image_set = mock.tap { |m| m.expects(:add).with(stub_image, stub_files) }
      mock_rss = mock(image_urls: [stub_image])
      GroupMe::FileStore.expects(:new).with(GroupMe::KRYPPIE_BOT_ACCESS_TOKEN).returns(stub_files)
      RSS.expects(:new).with(rss_url).returns(mock_rss)
      
      assert_nothing_raised do
        CelebrationFeed.add_image_urls(rss_url, mock_image_set)
      end
    end

    def test_add_image_urls_error
      rss_url = stub
      mock_image_set = mock
      error = StandardError.new("boom!")
      mock_rss = mock.tap { |m| m.expects(:image_urls).raises(error) }
      mock_logger = mock.tap { |m|
        m.expects(:message).with("Unable to load image feed")
        m.expects(:error).with(error)
      }
      RSS.expects(:new).with(rss_url).returns(mock_rss)
      CelebrationFeed.expects(:log).with(:error).twice.returns(mock_logger)

      assert_nothing_raised do
        CelebrationFeed.add_image_urls(rss_url, mock_image_set)
      end
    end
  end

  class RSSTest < Test::Unit::TestCase
    def setup
      @url = File.join(TEST_ROOT, 'fixtures', 'rss.xml')
      @feed = RSS.new(@url)
    end

    def image_urls
      images = @feed.image_urls
      assert_equal 1, images.count
      assert_include images, 'https://imgur.com/images.jpg'
    end

    def test_items
      items = @feed.items
      assert_equal 1, items.count
      assert_equal "RSS Solutions for Restaurants", items.first[:title]
    end
  end

  class FeedDescriptionImageParserTest < Test::Unit::TestCase
    def test_image_urls
      assert_equal %w(https://imgur.com/images.jpg), FeedDescriptionImageParser.new(image_fragment).image_urls
    end

    def test_nested_image_urls
      assert_equal %w(https://imgur.com/images.jpg), FeedDescriptionImageParser.new(nested_image_fragment).image_urls
    end

    private
    def image_fragment
      "test this <img src='https://imgur.com/images.jpg'>"
    end

    def nested_image_fragment
      "<p>this is a paragraph <img src='https://imgur.com/images.jpg'> </p>"
    end
  end
end
