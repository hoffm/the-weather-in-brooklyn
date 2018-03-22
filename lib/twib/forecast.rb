module Twib
  module Forecast
    module_function

    EXPANSIONS = {
      "mph" => "miles per hour",
      "%" => " percent",
    }.freeze

    INTRO_TEXT = "This is The Weather in Brooklyn. Welcome. " \
      "Here is your forecast for #{Time.now.strftime('%A, %B %e, %Y')}.".freeze

    def complete_ssmls
      [intro_ssml, *forecast_ssmls.take(5)]
    end

    def forecast_ssmls
      current_forecast.map do |period|
        period_ssml(*period)
      end
    end

    def intro_ssml
      to_ssml do |ssml|
        ssml.pause 5
        ssml.text INTRO_TEXT
        ssml.pause 3
      end
    end

    def period_ssml(name, details)
      to_ssml do |ssml|
        ssml.text "#{name}. #{details}"
        ssml.pause 5
      end
    end

    def current_forecast
      raw_current_forecast["periods"].map do |period|
        name = period["name"]
        details = expand_abbreviations!(period["detailedForecast"])
        [name, details]
      end
    end

    def expand_abbreviations!(text)
      EXPANSIONS.each { |expansion| text.gsub!(*expansion) }
      text
    end

    def to_ssml
      SsmlBuilder.build_ssml do |ssml|
        yield(ssml)
      end.to_xml
    end

    def raw_current_forecast
      connection = Faraday.new(
        url: NWS_API_HOST,
        headers: { accept: "application/ld+json" },
      )

      response = connection.get(NWS_API_PATH)
      JSON.parse(response.body)
    end
  end
end
