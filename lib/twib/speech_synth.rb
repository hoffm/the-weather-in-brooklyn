module Twib
  module SpeechSynth
    module_function

    def synthesize(ssml)
      POLLY_CLIENT.synthesize_speech(
        response_target: SPEECH_PATH,
        output_format: "mp3",
        voice_id: random_voice,
        text: ssml,
        text_type: "ssml"
      )
    end

    def random_voice
      all_voices = POLLY_CLIENT.describe_voices.to_h[:voices]
      all_voices.select do |voice|
        voice[:language_code].start_with?("en-")
      end.sample[:id]
    end

    class << self
      private :random_voice
    end
  end
end
