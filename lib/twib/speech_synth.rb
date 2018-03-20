module Twib
  module SpeechSynth
    module_function

    def bulk_synthesize(ssmls)
      tmp_files = []
      ssmls.each_with_index do |ssml, i|
        tmp_file = SPEECH_PATH.sub(".mp3", "_#{i}.mp3")
        synthesize(ssml, tmp_file)
        tmp_files << tmp_file
      end

      Sox.concatenate(tmp_files, SPEECH_PATH)
      FileUtils.rm(tmp_files)
    end

    def synthesize(ssml, response_target)
      POLLY_CLIENT.synthesize_speech(
        response_target: response_target,
        output_format: "mp3",
        voice_id: stable_random_voice,
        text: ssml,
        text_type: "ssml",
      )
    end

    def stable_random_voice
      @_voice ||= random_voice
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
