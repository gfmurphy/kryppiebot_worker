$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "test/unit"
require "bundler/setup"

Bundler.require(:default, :test)

require "flexmock/test_unit"



