require "group_me/urls"
require "group_me/file_store"
require "json"
require "logging"
require "mimemagic"
require "net/http"
require "net/http/post/multipart"
require "open-uri"

module GroupMe
  include Logging
  include GroupMe::Urls
  extend self

  KRYPPIE_GROUP_ID = ENV["GROUP"]
  KRYPPIE_BOT_ACCESS_TOKEN = ENV["ACCESS_TOKEN"]
  KRYPPIE_BOT_ID = ENV["TOKEN"]

  def get_group(group_id, token)
    resp = api_request(group_url(group_id), attempts: 2) do |uri, headers|
      headers.merge! "X-Access-Token" => token
      get(uri, headers)
    end

    handle_response(resp) do |body|
      JSON.parse(body).fetch("response")
    end
  end

  def get_leaderboard(group_id, period, token)
    resp = api_request(leaderboard_url(group_id), attempts: 2) do |uri, headers|
      headers.merge! "X-Access-Token" => token
      uri.query = URI.encode_www_form period: period
      get(uri, headers)
    end

    handle_response(resp) do |body|
      JSON.parse(body).fetch("response").fetch("messages")
    end
  end

  def get_message(group_id, message_id, token)
    resp = api_request(message_url(group_id, message_id), attempts: 2) do |uri, headers|
      headers.merge! "X-Access-Token" => token
      get(uri, headers)
    end

    handle_response(resp) do |body|
      JSON.parse(body).fetch("response").fetch("message")
    end
  end

  def post_as_bot(bot_id, message, picture_url=nil)
    resp = api_request(bot_post_url) do |uri, headers|
      data = { bot_id: bot_id, text: message }.tap { |d|
        d[:picture_url] = picture_url if picture_url
      }.to_json
      post(uri, headers, data)
    end

    handle_response(resp) do |body|
      log(:debug).message("Message sent successfully.")
    end
  end

  def upload_file(file_url, token)
    resp = api_request(image_service_url) do |uri, headers|
      uri.query = URI.encode_www_form access_token: token
      post_multipart(uri, headers, file_url)
    end

    handle_response(resp) do |body|
      JSON.parse(body).fetch("payload")
    end
  end

  def api_request(url, options={}, &b)
    attempts ||= options.fetch(:attempts, 1)
    uri = URI(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
      headers = { "Accept" => "application/json" }
      request = yield uri, headers
      http.request(request)
    end
  rescue => e
    retry unless (attempts -= 1).zero?
    log(:error).error(e)
    {}
  end

  private
  def handle_response(http_resp, &b)
    case http_resp
    when Net::HTTPSuccess
      yield http_resp.body if block_given?
    else
      log(:error).message("Unsuccessul API call: %s" % http_resp.inspect)
      {}
    end
  end

  def get(uri, headers)
    Net::HTTP::Get.new(uri.request_uri, initheader=headers)
  end

  def post(uri, headers, data)
    Net::HTTP::Post.new(uri.request_uri, initheader=headers).tap { |req|
      req.body = data
    }
  end

  def post_multipart(uri, headers, file_url)
    mime_type = MimeMagic.by_path(file_url).type
    Net::HTTP::Post::Multipart.new(uri.request_uri, 
      "file" => UploadIO.new(open(file_url), mime_type, File.basename(file_url)))
  end
end
