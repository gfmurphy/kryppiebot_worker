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
        @image ||= Boing::BoingImage.new(@image_set).select_image
      end
    end

    class BoingImage
      IMAGES = ['http://kryppiebot.herokuapp.com/images/arv.jpg']

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
