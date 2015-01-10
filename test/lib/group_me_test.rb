require 'test_helper'

class GroupMeTest < Test::Unit::TestCase
  def setup
    @stub_token = stub
    @mock_uri = mock
    @stub_request = stub
    @stub_response = stub
    @mock_headers = mock
  end

  def test_get_group
    @mock_headers.tap { |m| m.expects(:merge!).with("X-Access-Token" => @stub_token) }
    GroupMe.expects(:api_request).with(GroupMe.group_url(1), attempts: 2)
      .yields(@mock_uri, @mock_headers)
      .returns(@stub_response)
    GroupMe.expects(:get).with(@mock_uri, @mock_headers)
    GroupMe.expects(:handle_response).with(@stub_response).yields({"response" => "foo"}.to_json)

    assert_nothing_raised do
      GroupMe.get_group(1, @stub_token)
    end
  end

  def test_get_leaderboard
    period = "monthly"
    @mock_headers.expects(:merge!).with("X-Access-Token" => @stub_token)
    @mock_uri.expects(:query=).with(URI.encode_www_form(period: period))
    GroupMe.expects(:api_request).with(GroupMe.leaderboard_url(1), attempts: 2)
      .yields(@mock_uri, @mock_headers)
      .returns(@stub_response)
    GroupMe.expects(:get).with(@mock_uri, @mock_headers)
    GroupMe.expects(:handle_response).with(@stub_response)
      .yields({"response" => { "messages" => []}}.to_json)
      .returns({})

    assert_nothing_raised do
      assert_equal({}, GroupMe.get_leaderboard(1, period, @stub_token))
    end
  end

  def test_get_message
    @mock_headers.expects(:merge!).with("X-Access-Token" => @stub_token)
    GroupMe.expects(:api_request).with(GroupMe.message_url(1, 2), attempts: 2)
      .yields(@mock_uri, @mock_headers)
      .returns(@stub_response)
    GroupMe.expects(:get).with(@mock_uri, @mock_headers)
    GroupMe.expects(:handle_response).with(@stub_response)
      .yields({"response" => { "message" => {}}}.to_json)
      .returns({})

    assert_nothing_raised do
      assert_equal({}, GroupMe.get_message(1, 2, @stub_token))
    end
  end

  def test_post_as_bot
    data = { bot_id: 1, text: "foo" }.to_json
    GroupMe.expects(:api_request).with(GroupMe.bot_post_url).yields(@mock_uri, @mock_headers)
      .returns(@stub_response)
    GroupMe.expects(:post).with(@mock_uri, @mock_headers, data)
    GroupMe.expects(:handle_response).yields("success")

    assert_nothing_raised do
      GroupMe.post_as_bot(1, "foo")
    end
  end

  def test_upload_file
    stub_file_url = "http://imgur.com/image.jpg"
    stub_token = "foo"
    GroupMe.expects(:api_request).with(GroupMe.image_service_url).yields(@mock_uri, @mock_headers)
      .returns(@stub_response)
    @mock_uri.expects(:query=).with(URI.encode_www_form(access_token: stub_token))
    GroupMe.expects(:post_multipart).with(@mock_uri, @mock_headers, stub_file_url)
    GroupMe.expects(:handle_response).with(@stub_response).yields({"payload" => {"url" => "foo"}}.to_json)
      .returns({})

    assert_equal({}, GroupMe.upload_file(stub_file_url, stub_token))
  end

  def test_api_request
    mock_called = mock(called!: true)
    mock_http = mock.tap { |m| m.expects(:request).with(@stub_request) }
    Net::HTTP.expects(:start).with("example.com", 443, use_ssl: true).yields(mock_http)
      .returns(@stub_response)

    resp = GroupMe.api_request("https://example.com") do |uri, headers|
      mock_called.called!
      assert_equal URI("https://example.com"), uri
      assert_equal({ "Accept" => "application/json" }, headers)
      @stub_request
    end

    assert_equal @stub_response, resp
  end

  def test_api_request_error
    error = StandardError.new("boom!")
    mock_called = mock.tap { |m| m.expects(:called!).twice.returns(true) }
    mock_http = mock.tap { |m| m.expects(:request).twice.raises(error) }
    mock_logger = mock.tap { |m| m.expects(:error).with(error) }
    Net::HTTP.expects(:start).with("example.com", 443, use_ssl: true).twice.yields(mock_http)
    GroupMe.expects(:log).with(:error).returns(mock_logger)

    resp = GroupMe.api_request("https://example.com", attempts: 2) do |uri, headers|
      mock_called.called!
      assert_equal URI("https://example.com"), uri
      assert_equal({ "Accept" => "application/json" }, headers)
      @stub_request
    end

    assert_equal({}, resp)
  end
end
