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