class InitializingImageSet
  def initialize(image_set, images)
    @image_set = image_set
    @images = Array(images)
  end

  def random
    image = @image_set.random
    if image.nil?
      file_store = GroupMe::FileStore.new(GroupMe::KRYPPIE_BOT_ACCESS_TOKEN)
      @images.reduce([]) {|imgs, url|
        imgs << @image_set.add(url, file_store)["url"]
      }.compact.sample
    else
      image
    end
  end
end
