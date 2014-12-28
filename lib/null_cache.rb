class NullCache
  def fetch(key, options={}, &b)
    yield if block_given?
  end
end
