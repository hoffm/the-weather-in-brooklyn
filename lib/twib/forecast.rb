module Twib
  module Forecast
    module_function

    EXPANSIONS = {
      "mph" => "miles per hour",
      "%" => " percent",
    }.freeze

    INTRO_TEXT = "This is The Weather in Brooklyn. Welcome. " \
      "Here is your forecast for #{Time.now.strftime('%A, %B %e, %Y')}.".freeze

    def current_as_ssml
      SsmlBuilder.new do |ssml|
        ssml.speak_root do
          ssml.pause 5
          ssml.text INTRO_TEXT
          ssml.pause 3

          current_forecast.take(5).each do |name, details|
            ssml.text "#{name}. #{details}"
            ssml.pause 5
          end
        end
      end.to_xml
    end

    def current_forecast
      raw_current_forecast["periods"].map do |period|
        name = period["name"]
        details = period["detailedForecast"]
        EXPANSIONS.each { |expansion| details.gsub!(*expansion) }

        [name, details]
      end
    end

    def raw_current_forecast
      connection = Faraday.new(
        url: NWS_API_HOST,
        headers: { accept: "application/ld+json" },
      )

      response = connection.get(NWS_API_PATH)
      JSON.parse(response.body)
    end

    class << self
      private :current_forecast
      private :current_forecast
    end
  end
end
