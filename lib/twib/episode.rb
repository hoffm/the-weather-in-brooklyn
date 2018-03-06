module Twib
  class Episode
    attr_reader :number, :time

    class << self
      def build
        new(time: Time.now, number: next_number)
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
          bucket: ENV["S3_BUCKET"], prefix: "episodes/"
        ).contents.last.key
      end
    end

    def initialize(time:, number:)
      @number = number
      @time = time
    end

    def upload!(source_path:)
      File.open(source_path, 'rb') do |file|
        S3_CLIENT.put_object(
          acl: "public-read",
          bucket: ENV["S3_BUCKET"],
          key: s3_key,
          body: file
        )
      end
    end

    def audio_url
      "https://s3.amazonaws.com/#{ENV["S3_BUCKET"]}/#{s3_key}"
    end

    def s3_key
      "episodes/#{number}_#{time.strftime("%Y-%m-%d")}.mp3"
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
      time.rfc2822
    end

    private

    def date_text
      time.strftime("%A, %B %e, %Y")
    end
  end
end
