# frozen_string_literal: true

module Twib
  module Podcast
    module_function

    def build_and_upload_feed!(new_episode:)
      new_feed_xml = feed_with_new_episode(new_episode)
      upload_feed!(new_feed_xml)
    end

    def feed_with_new_episode(new_episode)
      # Download latest RSS feed
      existing_feed = Nokogiri::XML(existing_feed_xml)

      # Add new episode node
      RssBuilder.new do |rss|
        rss.podcast_root do |root|
          root.episode_item(new_episode.data)
          root << existing_feed.xpath('rss/channel/item').to_xml
        end
      end.to_xml
    end

    def upload_feed!(new_feed_xml)
      S3_CLIENT.put_object(
        content_type: 'application/xml',
        bucket: ENV.fetch('S3_PUBLIC_BUCKET', nil),
        key: ENV.fetch('S3_FEED_FILE_NAME', nil),
        body: new_feed_xml
      )
    end

    def existing_feed_xml
      S3_CLIENT.get_object(
        bucket: ENV.fetch('S3_PUBLIC_BUCKET', nil),
        key: ENV.fetch('S3_FEED_FILE_NAME', nil)
      ).body.read
    rescue Aws::S3::Errors::NoSuchKey
      ''
    end

    def feed_url
      "https://#{ENV.fetch('S3_PUBLIC_BUCKET', nil)}.s3.amazonaws.com/#{ENV.fetch('S3_FEED_FILE_NAME', nil)}"
    end

    def next_episode_number
      number_from_key(last_key) + 1
    end

    def number_from_key(key)
      return 0 if last_key.nil?

      key.split('/').last.split('_').first.to_i
    end

    def last_key
      last_episode = S3_CLIENT.list_objects_v2(
        bucket: ENV.fetch('S3_PUBLIC_BUCKET', nil),
        prefix: "#{ENV.fetch('S3_EPISODES_FOLDER', nil)}/"
      ).contents.last

      last_episode&.key
    end
  end
end
