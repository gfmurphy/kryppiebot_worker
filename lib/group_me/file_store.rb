module GroupMe
  class FileStore
    def initialize(token)
      @token = token
    end

    def put(url)
      GroupMe.upload_file(url, @token)
    end
  end
end
