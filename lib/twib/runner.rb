module Twib
  def self.run
    puts "Generating forecast"
    forecast_ssmls = Forecast.complete_ssmls

    puts "Synthesizing speech"
    SpeechSynth.bulk_synthesize(forecast_ssmls)

    puts "Downloading music"
    Music.download_random_song(target_path: MUSIC_PATH)

    puts "Mixing audio"
    Mixer.new(
      speech_path: SPEECH_PATH,
      music_path: MUSIC_PATH,
      target_path: MIX_PATH,
    ).mix

    puts "Uploading episode"
    episode = Episode.build(MIX_PATH)
    episode.upload!

    puts "\"#{episode.title}\" available at #{episode.audio_url}"
  end
end
