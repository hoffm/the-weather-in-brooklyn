# frozen_string_literal: true

module Twib
  class Episode
    attr_reader :audio_path, :number, :time

    class << self
      def build(audio_path)
        new(
          audio_path:,
          time: Time.current,
          number: Podcast.next_episode_number
        )
      end
    end

    def initialize(audio_path:, time:, number:)
      @audio_path = audio_path
      @number = number
      @time = time
    end

    def data
      {
        number:,
        title:,
        enclosure: {
          url: audio_url,
          length: audio_size,
          type: 'audio/mpeg'
        },
        pub_date:,
        duration: audio_duration,
        subtitle: short_summary,
        description: summary,
        language: 'en-us',
        image_url: PODCAST_ART_URL,
        guid: episode_code,
        author: PODCAST[:owner][:name]
      }
    end

    def upload_audio!
      File.open(audio_path, 'rb') do |file|
        S3_CLIENT.put_object(
          content_type: 'audio/mpeg',
          bucket: ENV.fetch('S3_PUBLIC_BUCKET', nil),
          key: s3_key,
          body: file
        )
      end
    end

    def audio_size
      File.new(audio_path).size
    end

    def audio_url
      "https://#{ENV.fetch('S3_PUBLIC_BUCKET', nil)}.s3.amazonaws.com/#{s3_key}"
    end

    def audio_duration
      Sox.duration_in_seconds(audio_path)
    end

    def s3_key
      "#{ENV.fetch('S3_EPISODES_FOLDER', nil)}/#{episode_code}.mp3"
    end

    def episode_code
      "#{number_string}_#{time.strftime('%Y-%m-%d')}"
    end

    def number_string
      number.to_s.rjust(5, '0')
    end

    def title
      "#{number}: #{Script.date_text}"
    end

    def short_summary
      'This is The Weather in Brooklyn. Welcome. ' \
        "Here is your forecast for #{Script.date_text}."
    end

    def summary
      <<~HTML
        <p>This is <i>The Weather in Brooklyn</i>. Welcome. Here is your forecast for #{Script.date_text}.</p>

        <p><i>The Weather in Brooklyn</i> was created by <a href="https://twitter.com/Hoffm/">Michael Hoffman</a> and is generated automatically. You can view and contribute to its <a href="https://github.com/hoffm/the-weather-in-brooklyn">source code</a>.</p>

        <p>Weather forecast courtesy of the <a href="https://www.weather.gov/">National Weather Service</a>. Music by <a href="http://jaschamusic.com/">Jascha Hoffman</a>. Audio logo by <a href="https://twitter.com/unclenatie">Nate Heller</a>. Photograph by <a href="https://www.alexmakotosimpson.com/">Alex Simpson</a>.</p>
      HTML
    end

    def pub_date
      time.rfc2822
    end
  end
end
