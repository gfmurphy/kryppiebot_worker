require "gingerice"
require "group_me"

module Listeners
  class GrammarNazi
    include GroupMe

    def initialize(redis)
      @redis = redis
      @image_set = ImageSet.new(ImageSet::JON, @redis, expires_in: 86400)
    end

    def listen(message)
      response = GrammarNazi::Response.new(@image_set, message["text"])
      if response.corrected? && !recent_correction?
        post_as_bot(KRYPPIE_BOT_ID, response.text, response.image)
        record_correction!
      end
    end

    private
    def key
      "grammar_nazi_responded"
    end

    def record_correction!
      @redis.multi do
        @redis.set(key, "1")
        @redis.expire(key, 3600)
      end
    end

    def recent_correction?
      @redis.get(key)
    end

    class Response
      def initialize(image_set, message)
        @image_set = image_set
        @message = message.to_s
        @corrected = parse
      end

      def corrected?
        Array(@corrected["corrections"]).count > 0 && image
      end

      def text
        "#{responses.sample} It's, \"#{@corrected["result"]}\""
      end

      def image
        @image ||= GrammarNazi::Image.new(@image_set).select_image
      end

      private
      def parse
        Gingerice::Parser.new.parse @message
      end

      def responses
        ["WTF?", "EGREGIOUS!", "Are you having a stroke?", "You're an idiot."]
      end
    end

    # TODO extract this pattern into generic concept. Boing listener uses same kind
    # of image seeder.
    class Image

      # TODO source images dynamically from kryppiebot.
      IMAGES = [
        'http://kryppiebot.herokuapp.com/images/jon/fish.jpg',
        'http://kryppiebot.herokuapp.com/images/jon/old.jpg',
        'http://kryppiebot.herokuapp.com/images/jon/pool_feet.jpg'
      ]

      def initialize(image_set)
        @image_set = image_set
      end

      def select_image
        image = @image_set.random
        if image.nil?
          file_store = GroupMe::FileStore.new(GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
          IMAGES.reduce([]) {|imgs, url|
            imgs << @image_set.add(url, file_store)["url"]
          }.compact.sample
        else
          image
        end
      end
    end
  end
end
