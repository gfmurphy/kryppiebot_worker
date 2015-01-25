require "initializing_image_set"
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
      if !recent_correction? && response.corrected?
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
        @redis.expire(key, expires)
      end
    end

    def expires
      43200 + rand(-3600..3600)
    end

    def recent_correction?
      @redis.get(key)
    end

    class Response
      # TODO source images dynamically from kryppiebot.
      IMAGES = [
        'http://kryppiebot.herokuapp.com/images/jon/fish.jpg',
        'http://kryppiebot.herokuapp.com/images/jon/old.jpg',
        'http://kryppiebot.herokuapp.com/images/jon/pool_feet.jpg',
        'http://kryppiebot.herokuapp.com/images/jon/teddy.png'
      ]

      def initialize(image_set, message)
        @image_set = image_set
        @message = message.to_s
      end

      def corrected?
        (@corrected ||= parse) && error_ratio > 0.125 && image
      end

      def text
        "#{responses.sample} It's, \"#{@corrected["result"]}\""
      end

      def image
        @image ||= InitializingImageSet.new(@image_set, IMAGES).random
      end

      private
      def error_ratio
        @corrected["corrections"].count / @message.split(/\W+/).count.to_f
      end

      def parse
        Gingerice::Parser.new.parse @message
      end

      def responses
        ["WTF?", "EGREGIOUS!", "Are you having a stroke?", "You're an idiot."]
      end
    end
  end
end
