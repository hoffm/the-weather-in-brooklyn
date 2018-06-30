module Twib
  class Mixer
    attr_accessor :logo_path, :music_path, :speech_path, :target_path

    def initialize(logo_path:, music_path:, speech_path:, target_path:)
      @logo_path = logo_path
      @music_path = music_path
      @speech_path = speech_path
      @target_path = target_path
    end

    def mix
      `./bin/mix.sh #{LOGO_PATH} #{music_path} #{speech_path}  #{target_path}`
      target_path
    end
  end
end
