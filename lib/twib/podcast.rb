module Twib
  module Podcast
    module_function

    def update_feed!(new_episode:)
      # Download latest RSS feed
      existing_feed = Nokogiri::XML(existing_feed_xml)

      # Add new episode node
      new_feed = RssBuilder.new do |rss|
        rss.podcast_root do |root|
          root << existing_feed.xpath("rss/channel/item").to_xml
          root.episode_item(new_episode.data)
        end
      end

      new_feed_xml = new_feed.to_xml

      # Upload new feed to twib/feed.rss
      S3_CLIENT.put_object(
        content_type: "application/xml",
        bucket: ENV["S3_PUBLIC_BUCKET"],
        key: ENV['S3_FEED_FILE_NAME'],
        body: new_feed_xml,
      )
    end

    def existing_feed_xml
      S3_CLIENT.get_object(
        bucket: ENV["S3_PUBLIC_BUCKET"],
        key: ENV["S3_FEED_FILE_NAME"],
      ).body.read
    rescue Aws::S3::Errors::NoSuchKey
      ''
    end

    def url
      "#{ENV["PUBLIC_HOST"]}/#{ENV["S3_FEED_FILE_NAME"]}"
    end

    def next_episode_number
      number_from_key(last_key) + 1
    end

    def number_from_key(key)
      key.split("/").last.split("_").first.to_i
    end

    def last_key
      S3_CLIENT.list_objects_v2(
        bucket: ENV["S3_PUBLIC_BUCKET"],
        prefix: ENV["S3_EPISODES_FOLDER"] + "/",
        ).contents.last.key
    end
  end
end
