require 'logging'
require 'open-uri'
require 'nokogiri'
require 'simple-rss'

module CelebrationFeed
  include Logging
  extend self

  def add_image_urls(rss_url, image_set)
    file_store = GroupMe::FileStore.new(ENV["KRYPPIE_BOT_ACCESS_TOKEN"])
    RSS.new(rss_url).image_urls.each do |image_url|
      image_set.add(image_url, file_store)
    end
  rescue => e
    log(:error).message("Unable to load image feed")
    log(:error).error(e)
  end

  class RSS
    def initialize(url)
      @url = url
    end

    def image_urls
      items.flat_map { |item| FeedDescriptionImageParser.new(CGI.unescapeHTML(item[:description].to_s)).image_urls }
    end

    def items
      parsed.items
    end

    private
    def parsed
      @parsed ||= SimpleRSS.parse(open(@url))
    end
  end

  class FeedDescriptionImageParser
    def initialize(body)
      @body = body
    end

    def image_urls
      Nokogiri::HTML.fragment(@body).xpath(".//img/@src").map(&:value)
    end
  end
end
