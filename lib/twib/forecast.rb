# frozen_string_literal: true

module Twib
  module Forecast
    module_function

    def data
      connection = Faraday.new(
        url: NWS_API_HOST,
        headers: { accept: 'application/ld+json' }
      )

      response = connection.get(NWS_API_PATH)
      JSON.parse(response.body)
    end
  end
end
