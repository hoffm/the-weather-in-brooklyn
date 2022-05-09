# frozen_string_literal: true

module Twib
  module Logo
    module_function

    def download(target_path:)
      S3_CLIENT.get_object(
        response_target: target_path,
        bucket: ENV.fetch('S3_PRIVATE_BUCKET', nil),
        key: LOGO_S3_KEY
      )
    end
  end
end
