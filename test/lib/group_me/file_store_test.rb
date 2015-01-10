require "test_helper"
module GroupMe
  class FileStoreTest < Test::Unit::TestCase
    def setup
      @url = 'foo'
      @token = 'bar'
    end

    def test_put
      GroupMe.expects(:upload_file).with(@url, @token)
      assert_nothing_raised do
        FileStore.new(@token).put(@url)
      end
    end
  end
end
