module Twib
  class Episode
    attr_reader :audio_path, :number, :time

    class << self
      def build(audio_path)
        new(
          audio_path: audio_path,
          time: Time.current,
          number: next_number,
        )
      end

      private

      def next_number
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

    def initialize(audio_path:, time:, number:)
      @audio_path = audio_path
      @number = number
      @time = time
    end

    def store_json!
      DataUtils.append_episode_data!(json_for_rss)
    end

    def json_for_rss
      {
        number: number,
        title: title,
        enclosure: {
          url: audio_url,
          length: audio_size,
          type: "audio/mpeg",
        },
        guid: audio_url,
        pub_date: pub_date,
        duration: audio_duration,
        subtitle: short_summary,
        description: summary,
        language: "en-us",
        image_url: ""
      }
    end

    def upload!
      File.open(audio_path, "rb") do |file|
        S3_CLIENT.put_object(
          acl: "public-read",
          bucket: ENV["S3_MEDIA_BUCKET"],
          key: s3_key,
          body: file,
        )
      end
    end

    def audio_size
      File.new(audio_path).size
    end

    def audio_url
      "https://s3.amazonaws.com/#{ENV['S3_MEDIA_BUCKET']}/#{s3_key}"
    end

    def audio_duration
      Sox.duration_in_seconds(audio_path)
    end

    def s3_key
      "episodes/#{number}_#{time.strftime('%Y-%m-%d')}.mp3"
    end

    def title
      "Episode #{number}: #{date_text}"
    end

    def short_summary
      "This is The Weather in Brooklyn. Welcome. " \
      "Here is your forecast for #{date_text}."
    end

    def summary
      <<~HTML
        #{short_summary}

        -----

        <i>The Weather in Brooklyn</i> was created by Michael Hoffman.
        Follow Michael on Twitter at <href="https://twitter.com/Hoffm/">@hoffm</a>.

        Episode music by Jascha Hoffman.
        For more, visit Jascha at <a href="http://jaschamusic.com/">jaschamusic.com</a>.
HTML
    end

    def pub_date
      (time.beginning_of_day + 6.hours).rfc2822
    end

    private

    def date_text
      time.strftime("%A, %B %e, %Y")
    end
  end
end
