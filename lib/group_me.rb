require "json"
require "logging"
require "net/http"

module GroupMe
  include Logging
  extend self

  def post_as_bot(bot_id, message)
    attempts ||= 3
    uri = URI(bot_post_url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http| 
      request = Net::HTTP::Post.new(uri.request_uri, initheader={ "Content-Type" => "application/json"})
      request.body = { bot_id: bot_id, text: message }.to_json
      resp = http.request(request)

      case resp
      when Net::HTTPSuccess
        log(:debug).message("Message sent successfully.")
      else
        log(:error).message("Message error: %s, %s" % [resp.code, resp.body])
      end
    end
  rescue => e
    retry unless (attempts -= 1).zero?
    log(:error).error(e)
  end

  private
  def bot_post_url
    "https://api.groupme.com/v3/bots/post"
  end
end
