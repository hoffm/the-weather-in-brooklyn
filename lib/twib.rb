require "aws-sdk-polly"
require "aws-sdk-s3"
require "dotenv"
require "faraday"
require "json"
require "nokogiri"

Dotenv.load

TWIB_APP_PATH = File.expand_path("../", __FILE__) + "/twib"
Dir["#{TWIB_APP_PATH}/**/*.rb"].each { |file| require file }

module Twib
  def self.run
    puts "Generating forecast"
    forecast_ssml = Forecast.current_as_ssml

    puts "Synthesizing speech"
    SpeechSynth.synthesize(forecast_ssml)

    puts "Downloading music"
    Music.download_random_song(target_path: MUSIC_PATH)

    puts "Mixing audio"
    Mixer.new(
      speech_path: SPEECH_PATH,
      music_path: MUSIC_PATH,
      target_path: MIX_PATH
    ).mix

    puts "Uploading episode"
    episode = Episode.build
    episode.upload!(source_path: MIX_PATH)

    puts "\"#{episode.title}\" available at #{episode.audio_url}"
  end
end

Twib.run