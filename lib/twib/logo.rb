module Twib
  module Logo
    module_function

    def download(target_path:)
      S3_CLIENT.get_object(
        response_target: target_path,
        bucket: ENV["S3_MEDIA_BUCKET"],
        key: LOGO_S3_KEY,
      )
    end
  end
end
