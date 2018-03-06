# frozen_string_literal: true
module Twib
  NWS_API_HOST = "https://api.weather.gov"
  NWS_API_PATH = "/gridpoints/OKX/33,32/forecast"

  S3_CLIENT = Aws::S3::Client.new(region: "us-east-1")
  POLLY_CLIENT = Aws::Polly::Client.new(region: "us-east-1")

  TMP_DIR = File.expand_path("./", "tmp")
  MUSIC_PATH = File.join(TMP_DIR, "raw_music.mp3")
  SPEECH_PATH = File.join(TMP_DIR, "raw_speech.mp3")
  MIX_PATH = File.join(TMP_DIR, "final_mix.mp3")
end