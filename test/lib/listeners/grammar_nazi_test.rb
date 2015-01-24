require 'test_helper'

module Listeners
  class GrammarNaziTest < Test::Unit::TestCase
    def setup
      @mock_redis = mock
    end

    def test_listen_with_bad_grammar
      message = { "text" => "Your a idiot"}
      stub_response = stub(corrected?: true, text: "foo", image: "http://example.com/image.jpg")
      GrammarNazi::Response.expects(:new).returns(stub_response)
      @mock_redis.expects(:get).returns(nil)
      @mock_redis.expects(:multi).yields
      @mock_redis.expects(:set)
      @mock_redis.expects(:expire)
      grammar_nazi = GrammarNazi.new(@mock_redis)
      grammar_nazi.expects(:post_as_bot).with(GroupMe::KRYPPIE_BOT_ID, "foo", "http://example.com/image.jpg")
      assert_nothing_raised do
        grammar_nazi.listen(message)
      end
    end

    def test_listen_to_ok_grammar
      message = {"text" => "You're an idiot"}
      stub_response = stub(corrected?: false)
      GrammarNazi::Response.expects(:new).returns(stub_response)
      grammar_nazi = GrammarNazi.new(@mock_redis)
      grammar_nazi.expects(:post_as_bot).never
      assert_nothing_raised do
        grammar_nazi.listen(message)
      end
    end
  end

  class GrammarNazi::ResponseTest < Test::Unit::TestCase
    def setup
      @image_set = mock
    end

    def test_corrected_on_good_sentence
      mock_parser = mock(parse: {"corrections" => []})
      Gingerice::Parser.expects(:new).returns(mock_parser)
      response = GrammarNazi::Response.new(@image_set, "You're an idiot")
      assert !response.corrected?
    end

    def test_corrected_on_bad_sentence_with_no_image
      mock_parser = mock(parse: {"corrections" => [stub, stub]})
      mock_image = mock(random: nil)
      Gingerice::Parser.expects(:new).returns(mock_parser)
      InitializingImageSet.expects(:new).returns(mock_image)
      response = GrammarNazi::Response.new(@image_set, "Your a idiot")
      assert !response.corrected?
    end

    def text_corrected_on_bad_sentence_with_image
      mock_parser = mock(parse: {"corrections" => [stub, stub]})
      mock_image = mock(random: stub)
      Gingerice::Parser.expects(:new).returns(mock_parser)
      InitializingImageSet.expects(:new).returns(mock_image)
      response = GrammarNazi::Response.new(@image_set, "Your a idiot")
      assert response.corrected?
    end

    def text_text
      mock_parser = mock(parse: {"result" => "corrected"})
      Gingerice::Parser.expects(:new).returns(mock_parser)
      response = GrammarNazi::Response.new(@image_set, "Your a idiot")
      assert_match(/It's, corrected/, response.text)
    end

    def test_image
      stub_image = stub(random: "foo")
      InitializingImageSet.expects(:new).with(@image_set, GrammarNazi::Response::IMAGES).returns(stub_image)
      response = GrammarNazi::Response.new(@image_set, "Your a idiot")
      assert_equal "foo", response.image
    end
  end
end
