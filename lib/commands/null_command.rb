require "group_me"

module Commands
  class NullCommand
    include GroupMe

    def call(message)
      name = message["name"].to_s.split(/\s+/).first
      post_as_bot(KRYPPIE_BOT_ID, generate_response(name))
    end

    private
    def generate_response(name)
      "I don't get it.".tap { |resp|
        resp.gsub!('.', ", #{name}.") unless name.nil?
      }
    end
  end
end
