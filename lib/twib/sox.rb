module Twib
  module Sox
    module_function

    def duration_in_seconds(audio_path)
      `soxi -D #{audio_path}`.strip.to_f.ceil
    end

    def concatenate(source_paths, target_path)
      `sox #{source_paths.join(" ")} #{target_path}`
    end
  end
end
