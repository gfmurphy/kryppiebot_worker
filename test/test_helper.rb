$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "bundler/setup"
Bundler.require(:default, :test)

require "test/unit"
require "mocha/test_unit"
require "mocha/mini_test"

