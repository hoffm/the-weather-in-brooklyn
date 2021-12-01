module Twib
  class Episode
    attr_reader :audio_path, :number, :time

    class << self
      def build(audio_path)
        new(
          audio_path: audio_path,
          time: Time.current,
          number: Podcast.next_episode_number,
        )
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
        pub_date: pub_date,
        duration: audio_duration,
        subtitle: short_summary,
        description: summary,
        language: "en-us",
        image_url: "https://d3vv6lp55qjaqc.cloudfront.net/items/3U0m2c0O2U393i1r1v3I/tst-1764_preview%20(2).png"
      }
    end

    def upload_audio!
      File.open(audio_path, "rb") do |file|
        S3_CLIENT.put_object(
          content_type: "audio/mpeg",
          acl: "public-read",
          bucket: ENV["S3_PUBLIC_BUCKET"],
          key: s3_key,
          body: file,
        )
      end
    end

    def audio_size
      File.new(audio_path).size
    end

    def audio_url
      "https://s3.amazonaws.com/#{ENV['S3_PUBLIC_BUCKET']}/#{s3_key}"
    end

    def audio_duration
      Sox.duration_in_seconds(audio_path)
    end

    def s3_key
      "episodes/#{number.to_s.rjust(5, "0")}_#{time.strftime('%Y-%m-%d')}.mp3"
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
        #{short_summary}<br/>

        <i>The Weather in Brooklyn</i> was created by <a href="https://twitter.com/Hoffm/">Michael Hoffman</a> and is generated automatically. You can view and contribute to its <a href="https://github.com/hoffm/the-weather-in-brooklyn">source code</a>.<br/>
        
        Music by <a href="http://jaschamusic.com/">Jascha Hoffman</a>. Audio logo by <a href="https://twitter.com/unclenatie">Nate Heller</a>. Photograph by <a href="https://www.alexmakotosimpson.com/">Alex Simpson</a>.
HTML
    end

    def pub_date
      time.rfc2822
    end

    private

    def date_text
      time.strftime("%A, %B %e, %Y")
    end
  end
end
