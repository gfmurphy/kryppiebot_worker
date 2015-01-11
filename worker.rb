$:.unshift(File.join(File.dirname(__FILE__), "lib"))

require "celebration_feed"
require "commands"
require "image_set"
require "json"
require "kryppiebot"
require "rufus/scheduler"
require "shit_bfl_says"
require "tweet_popular_message"
require "twitter"
require "user_recent_messages"

$stdout.sync = true
Logging.logger = Kryppiebot.logger

Rufus::Scheduler.singleton.every '5m' do
  Kryppiebot.redis do |redis| 
    TweetPopularMessage.watch_bfl(Redis.new(url: REDIS_URL))
  end
end

Rufus::Scheduler.singleton.cron '0 0,12 * * *' do
  Kryppiebot.redis do |redis| 
    CelebrationFeed.add_image_urls(ENV["CELEBRATE_URL"], ImageSet.new(ImageSet::CONGRATS, redis))
  end
end

Kryppiebot.redis do |redis|
  redis.subscribe("groupme:message") do |on|
    on.message do |channel, message|
      Commands.handler(JSON.parse(message.to_s)).call
    end
  end
end


