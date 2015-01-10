TEST_ROOT = File.dirname(__FILE__)

$:.unshift(File.join(TEST_ROOT, "..", "lib"))
require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require "bundler/setup"
Bundler.require(:default, :test)

require "test/unit"
require "mocha/test_unit"
require "mocha/mini_test"



