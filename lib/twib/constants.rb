# frozen_string_literal: true

module Twib
  # Weather.gov
  NWS_API_HOST = 'https://api.weather.gov'
  NWS_API_PATH = '/gridpoints/OKX/33,32/forecast'

  # AWS
  S3_CLIENT = Aws::S3::Client.new
  POLLY_CLIENT = Aws::Polly::Client.new
  LOGO_S3_KEY = 'logo/logo.mp3'

  # Temp files
  TMP_DIR = File.expand_path('./', 'tmp')
  MUSIC_PATH = File.join(TMP_DIR, 'raw_music.mp3')
  SPEECH_PATH = File.join(TMP_DIR, 'raw_speech.mp3')
  LOGO_PATH = File.join(TMP_DIR, 'logo.mp3')
  MIX_PATH = File.join(TMP_DIR, 'final_mix.mp3')

  # Static data
  PODCAST_TITLE = 'The Weather in Brooklyn'
  PODCAST_ART_URL = "https://#{ENV['S3_PUBLIC_BUCKET']}.s3.amazonaws.com/art.jpg".freeze
  PODCAST_HOMEPAGE = 'https://michaelshoffman.com/the-weather-in-brooklyn'

  PODCAST = {
    title: PODCAST_TITLE,
    link: PODCAST_HOMEPAGE,
    language: 'en-us',
    description: 'An automated podcast bringing you your daily weather forecast for Brooklyn, NY.',
    editor: 'michael.s.hoffman@gmail.com (Michael Hoffman)',
    categories: [
      ['Society & Culture', ['Places & Travel']],
      ['Science', ['Nature']]
    ],
    owner: {
      name: 'Michael S. Hoffman',
      email: 'michael.s.hoffman@gmail.com'
    },
    itunes_type: 'episodic',
    image: {
      url: PODCAST_ART_URL,
      link: PODCAST_HOMEPAGE,
      title: PODCAST_TITLE
    }
  }.freeze
end
