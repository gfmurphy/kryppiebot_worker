$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "bundler/setup"
Bundler.require(:default, :test)

require "test/unit"
require "mocha/test_unit"
require "mocha/mini_test"

