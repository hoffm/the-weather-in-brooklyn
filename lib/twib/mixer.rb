class Mixer
  attr_accessor :speech_path, :music_path, :target_path

  def initialize(speech_path:, music_path:, target_path:)
    @speech_path = speech_path
    @music_path = music_path
    @target_path = target_path
  end

  def mix
    `./bin/mix.sh #{speech_path} #{music_path} #{target_path}`
    target_path
  end
end
