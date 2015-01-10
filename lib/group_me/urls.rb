module GroupMe
  module Urls
    extend self

    API_ENDPOINT = "https://api.groupme.com/v3"

    def group_url(group_id)
      [API_ENDPOINT, "groups/%s" % group_id].join("/")
    end

    def leaderboard_url(group_id)
      [API_ENDPOINT, "groups/%s/likes" % group_id].join("/")
    end

    def message_url(group_id, message_id)
      params = { group_id: group_id, message_id: message_id }
      [API_ENDPOINT, "groups/%{group_id}/messages/%{message_id}" % params].join("/")
    end

    def bot_post_url
      [API_ENDPOINT, "bots", "post"].join("/")
    end

    def image_service_url
      "https://image.groupme.com/pictures"
    end
  end
end
