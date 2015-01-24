require "initializing_image_set"
require "group_me"

module Listeners
  class Boing
    include GroupMe

    def initialize(redis)
      @redis = redis
      @image_set = ImageSet.new(ImageSet::BOING, @redis, expires_in: 86400)
    end

    def listen(message)
      response = Boing::BoingResponse.new(@image_set, message["text"])
      post_as_bot(KRYPPIE_BOT_ID, response.text, response.image) if response.boing?
    end

    private
    class BoingResponse
      IMAGES = ['http://kryppiebot.herokuapp.com/images/arv.jpg']

      attr_reader :text

      def initialize(image_set, message)
        @image_set = image_set
        @message = message.to_s
        @text = ""
      end

      def boing?
        @message =~ /\bboing\b/i && image
      end

      def image
        @image ||= InitializingImageSet.new(@image_set, IMAGES).random
      end
    end
  end
end
