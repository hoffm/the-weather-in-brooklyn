module Twib
  module DataUtils
    module_function

    def store_feed!(feed_xml)
      File.open(rss_episodes_file_path, "w") do |f|
        f.write(feed_xml)
      end
      rss_episodes_file_path
    end

    def append_episode_data!(episode_data)
      data = latest_episodes_data << episode_data

      File.open(json_episodes_file_path, "w") do |f|
        f.write(JSON.pretty_generate(data))
      end
    end

    def rss_episodes_file_path
      File.join(RSS_DIR, "#{Time.now.to_i}.xml")
    end

    def json_episodes_file_path
      File.join(JSON_DIR, "#{Time.now.to_i}.json")
    end

    def latest_episodes_data
      if latest_episodes_json_path.present?
        JSON.parse(File.read(latest_episodes_json_path))
      else
        []
      end
    end

    def latest_episodes_json_path
      Dir.glob(JSON_DIR + "/*.json").sort.last
    end
  end
end
