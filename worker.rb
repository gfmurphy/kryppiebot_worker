$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require "commands"
require "json"
require "kryppiebot"

$stdout.sync = true
Logging.logger = Kryppiebot.logger

Kryppiebot.redis.subscribe("groupme:message") do |on|
  on.message do |channel, message|
    Commands.handler(JSON.parse(message.to_s)).call
  end
end



