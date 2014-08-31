require "json"
require "logging"
require "net/http"

module GroupMe
  include Logging
  extend self

  KRYPPIE_GROUP_ID = ENV["GROUP"]
  KRYPPIE_BOT_ACCESS_TOKEN = ENV["ACCESS_TOKEN"]
  KRYPPIE_BOT_ID = ENV["TOKEN"]

  def get_message(group_id, message_id, token)
    attempts ||= 3
    uri = URI(get_message_url(group_id, message_id))
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      headers = {
        "Content-Type" => "application/json",
        "X-Access-Token" => token
      }
      request = Net::HTTP::Get.new(uri.request_uri, initheader=headers)
      resp = http.request(request)

      case resp
      when Net::HTTPSuccess
        JSON.parse(resp.body).fetch("response").fetch("message")
      else
        log(:error).message("Unable to find message: %s" % resp.body)
        {}
      end
    end
  rescue => e
    retry unless (attempts -= 1).zero?
    log(:error).error(e)
    {}
  end

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
  def get_message_url(group_id, message_id)
    "https://api.groupme.com/v3/groups/%s/messages/%s" % [group_id, message_id]
  end

  def bot_post_url
    "https://api.groupme.com/v3/bots/post"
  end
end
