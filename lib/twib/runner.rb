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

    puts "Uploading episode audio"
    episode = Episode.build(MIX_PATH)
    episode.upload_audio!

    puts "Uploading podcast RSS feed"
    episode.store_json!
    Podcast.generate_and_upload_feed!

    puts "New episode audio available at #{episode.audio_url}."
    puts "Updated podcast RSS feed available at #{Podcast.url}."
  end
end
