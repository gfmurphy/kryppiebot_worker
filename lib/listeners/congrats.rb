require "group_me"

module Listeners
  class Congrats
    include GroupMe

    def initialize(redis)
      @redis = redis
      @image_set = ImageSet.new(ImageSet::CONGRATS, @redis)
    end

    def listen(message)
      text = message["text"]
      resp = CongratsMessage.new(text).response
      if resp.congrats? && !recent_response?(resp.name)
        post_as_bot(KRYPPIE_BOT_ID, resp.text, @image_set.random)
        record_response(resp.name)
      end
    end

    private
    def recent_response?(name)
      @redis.get(response_key(name))
    end

    def record_response(name)
      key = response_key(name)
      @redis.multi do
        @redis.set(key, "1")
        @redis.expires(key, 3600)
      end
    end

    def response_key(name)
      [ImageSet::CONGRATS, 'responses', name].compact.join(":")
    end

    class CongratsMessage
      def self.possible_responses
        ['Mazel tov', 'Cheers', 'Congrats', 'gz', 'Gratz', 'Hip Hip', 
         'Felicitations', 'Kudos', 'Props', 'Hats off']
      end

      def initialize(message)
        @message = message.to_s
      end

      def response
        CongratsResponse.new(*parse_message)
      end

      def parse_message
        match = @message.match(message_pattern)
        if match
          [select_response, match_name(match[2])]
        else
          []
        end
      end

      private
      def match_name(name)
        return name if name.nil?
        name.gsub(/\W/, '').capitalize
      end

      def message_pattern
        /\b(congrats|mazel tov|cheers|gratz|kudos|props)(,\s+\w+)?\b/i
      end

      def select_response
        CongratsMessage.possible_responses.sample
      end
    end
      
    class CongratsResponse
      attr_reader :name

      def initialize(*args)
        @text = args[0]
        @name = args[1]
      end

      def text
        [@text, @name].compact.join(", ").tap { |t| t << "!" unless t.empty? }
      end

      def congrats?
        !text.empty?
      end
    end
  end
end
