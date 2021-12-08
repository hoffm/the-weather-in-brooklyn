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
        bucket: ENV['S3_PUBLIC_BUCKET'],
        key: ENV['S3_FEED_FILE_NAME'],
        body: new_feed_xml
      )
    end

    def existing_feed_xml
      S3_CLIENT.get_object(
        bucket: ENV['S3_PUBLIC_BUCKET'],
        key: ENV['S3_FEED_FILE_NAME']
      ).body.read
    rescue Aws::S3::Errors::NoSuchKey
      ''
    end

    def feed_url
      "https://#{ENV['S3_PUBLIC_BUCKET']}.s3.amazonaws.com/#{ENV['S3_FEED_FILE_NAME']}"
    end

    def next_episode_number
      number_from_key(last_key) + 1
    end

    def number_from_key(key)
      key.split('/').last.split('_').first.to_i
    end

    def last_key
      S3_CLIENT.list_objects_v2(
        bucket: ENV['S3_PUBLIC_BUCKET'],
        prefix: "#{ENV['S3_EPISODES_FOLDER']}/"
      ).contents.last.key
    end
  end
end
