require "json"
require "logging"
require "net/http"

module GroupMe
  include Logging
  extend self

  KRYPPIE_GROUP_ID = ENV["GROUP"]
  KRYPPIE_BOT_ACCESS_TOKEN = ENV["ACCESS_TOKEN"]
  KRYPPIE_BOT_ID = ENV["TOKEN"]

  def get_leaderboard(group_id, period, token)
    resp = api_request(get_leaderboard_url(group_id), attempts: 2) do |uri, headers|
      headers.merge! "X-Access-Token" => token
      uri.query = URI.encode_www_form period: period
      Net::HTTP::Get.new(uri.request_uri, initheader=headers)
    end

    case resp
    when Net::HTTPSuccess
      JSON.parse(resp.body).fetch("response").fetch("messages")
    else
      log(:error).message("Unable to fetch group leaderboard %s" % resp.body)
      {}
    end
  end

  def get_message(group_id, message_id, token)
    resp = api_request(get_message_url(group_id, message_id), attempts: 2) do |uri, headers|
      headers.merge! "X-Access-Token" => token
      Net::HTTP::Get.new(uri.request_uri, initheader=headers)
    end

    case resp
    when Net::HTTPSuccess
      JSON.parse(resp.body).fetch("response").fetch("message")
    else
      log(:error).message("Unable to find message: %s" % resp.body)
      {}
    end
  end

  def post_as_bot(bot_id, message)
    resp = api_request(bot_post_url) do |uri, headers|
      Net::HTTP::Post.new(uri.request_uri, initheader=headers).tap { |req|
        req.body = { bot_id: bot_id, text: message }.to_json
      }
    end

    case resp
    when Net::HTTPSuccess
      log(:debug).message("Message sent successfully.")
    else
      log(:error).message("Message error: %s, %s" % [resp.code, resp.body])
    end
  end

  private
  def api_request(url, options={}, &b)
    attempts ||= options.fetch(:attempts, 1)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      headers = { "Content-Type" => "application/json" }
      request = yield uri, headers
      http.request(request)
    end
  rescue => e
    retry unless (attempts -= 1).zero?
    log(:error).error(e)
    {}
  end

  def get_leaderboard_url(group_id)
    params = { group_id: group_id }
    "https://api.groupme.com/v3/groups/%{group_id}/likes" % params
  end

  def get_message_url(group_id, message_id)
    params = {group_id: group_id, message_id: message_id }
    "https://api.groupme.com/v3/groups/%{group_id}/messages/%{message_id}" % params
  end

  def bot_post_url
    "https://api.groupme.com/v3/bots/post"
  end
end
