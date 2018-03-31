# frozen_string_literal: true

module Twib
  # Weather.gov
  NWS_API_HOST = "https://api.weather.gov"
  NWS_API_PATH = "/gridpoints/OKX/33,32/forecast"

  # AWS
  S3_CLIENT = Aws::S3::Client.new(region: "us-east-1")
  POLLY_CLIENT = Aws::Polly::Client.new(region: "us-east-1")

  def self.expand_path(path)
    File.expand_path("./", path)
  end

  # Temp files
  MUSIC_PATH = expand_path("tmp/raw_music.mp3")
  SPEECH_PATH = expand_path("tmp/raw_speech.mp3")
  MIX_PATH = expand_path("tmp/final_mix.mp3")

  # Data files
  JSON_DIR = expand_path("data/json")
  RSS_DIR = expand_path("data/rss")

  # Static data

  PODCAST = {
    title: "The Weather in Brooklyn",
    link: "https://twib.nyc",
    language: "en-us",
    description: "Your daily weather forecast for Brooklyn, NY",
    editor: "michael.s.hoffman@gmail.com (Michael Hoffman)",
    categories: [
      ["Society & Culture",  ["Places & Travel"]],
      ["Science & Medicine", ["Natural Sciences"]],
    ],
    owner: {
      name: "Michael S. Hoffman",
      email: "michael.s.hoffman@gmail.com"
    },
    itunes_type: "episodic",
    image: {
      url: "https://d3vv6lp55qjaqc.cloudfront.net/items/1G2P3n2T3d2Y3Y0x2q2O/twib.png",
      link: "https://twib.nyc",
      title: "The Weather in Brooklyn"
    }
  }
end
