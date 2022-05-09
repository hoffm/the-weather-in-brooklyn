# frozen_string_literal: true

module Twib
  module Music
    module_function

    def download_random_song(target_path:)
      download_song(song_key: random_song_key, target_path:)
    end

    def all_songs
      S3_CLIENT.list_objects_v2(
        bucket: ENV.fetch('S3_PRIVATE_BUCKET', nil),
        prefix: 'music/'
      ).contents.select do |s3_obj|
        s3_obj.size.positive?
      end
    end

    def download_song(song_key:, target_path:)
      S3_CLIENT.get_object(
        response_target: target_path,
        bucket: ENV.fetch('S3_PRIVATE_BUCKET', nil),
        key: song_key
      )
    end

    def random_song_key
      all_songs.sample.key
    end

    class << self
      private :all_songs
      private :download_song
      private :random_song_key
    end
  end
end
