module Twib
  module Podcast
    module_function

    def generate_and_upload_feed!
      feed_file_path = generate_feed!

      File.open(feed_file_path, "rb") do |file|
        S3_CLIENT.put_object(
          content_type: "application/xml",
          acl: "public-read",
          bucket: ENV["S3_RSS_BUCKET"],
          key: ENV["S3_RSS_KEY"],
          body: file,
        )
      end
    end

    def url
      "#{ENV["PUBLIC_HOST"]}/#{ENV["S3_RSS_KEY"]}"
    end

    def generate_feed!
      DataUtils.store_feed!(
        RssBuilder.build_podcast_feed.to_xml
      )
    end

    def next_episode_number
      number_from_key(last_key) + 1
    end

    def number_from_key(key)
      key.split("/").last.split("_").first.to_i
    end

    def last_key
      S3_CLIENT.list_objects_v2(
        bucket: ENV["S3_MEDIA_BUCKET"],
        prefix: "episodes/",
        ).contents.last.key
    end
  end
end
