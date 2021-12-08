# frozen_string_literal: true

module Twib
  module Forecast
    module_function

    def data
      uri = URI(NWS_API_HOST + NWS_API_PATH)
      headers = { 'Accept' => 'application/ld+json' }
      response = Net::HTTP.get(uri, headers)
      JSON.parse(response)
    end
  end
end
