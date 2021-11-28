# frozen_string_literal: true

module Twib
  # Weather.gov
  NWS_API_HOST = "https://api.weather.gov"
  NWS_API_PATH = "/gridpoints/OKX/33,32/forecast"

  # AWS
  S3_CLIENT = Aws::S3::Client.new
  LOGO_S3_KEY = "logo/logo.mp3"

  def self.expand_path(path)
    File.expand_path("./", path)
  end

  # Temp files
  MUSIC_PATH = expand_path("tmp/raw_music.mp3")
  SPEECH_PATH = expand_path("tmp/raw_speech.mp3")
  LOGO_PATH = expand_path("tmp/logo.mp3")
  MIX_PATH = expand_path("tmp/final_mix.mp3")

  # Data files
  JSON_DIR = expand_path("data/json")
  RSS_DIR = expand_path("data/rss")

  # Static data
  PODCAST_TITLE = "The Weather in Brooklyn"
  PODCAST_HOMEPAGE = "https://twib.nyc"

  PODCAST = {
    title: PODCAST_TITLE,
    link: PODCAST_HOMEPAGE,
    language: "en-us",
    description: "Your daily weather forecast for Brooklyn, NY",
    editor: "michael.s.hoffman@gmail.com (Michael Hoffman)",
    categories: [
      ["Society & Culture",  ["Places & Travel"]],
      ["Science", ["Nature"]]
    ],
    owner: {
      name: "Michael S. Hoffman",
      email: "michael.s.hoffman@gmail.com"
    },
    itunes_type: "episodic",
    image: {
      url: "https://twib-production.s3.amazonaws.com/images/twib.jpg",
      link: PODCAST_HOMEPAGE,
      title: PODCAST_TITLE
    }
  }
end
