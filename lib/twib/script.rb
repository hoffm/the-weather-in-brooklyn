module Twib
  module Script
    module_function

    TXT_EXPANSIONS = {
      "mph" => "miles per hour",
      "%" => " percent",
    }.freeze

    INTRO_TEXT = <<~TEXT
      This is The Weather in Brooklyn. Welcome. 
      Here is your forecast for #{Time.now.strftime('%A, %B %e, %Y')}.
    TEXT

    CREDITS_TEXT = <<~TEXT
      The Weather in Brooklyn is an automated podcast by Michael Hoffman.
      Music by Jascha Hoffman.
      Audio logo by Nate Heller.
      Podcast photograph by Alex Simpson.
    TEXT

    def complete_ssmls
      [
        intro_ssml,
        *forecast_ssmls.take(3),
        credits_ssml,
        sign_off_ssml
      ]
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

    def credits_ssml
      to_ssml do |ssml|
        ssml.pause 10
        ssml.text CREDITS_TEXT
        ssml.pause 5
      end
    end

    def sign_off_ssml
      to_ssml do |ssml|
        ssml.text "Have a lovely day Brooklyn."
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
      Forecast.data["periods"].map do |period|
        name = period["name"]
        details = expand_abbreviations!(period["detailedForecast"])
        [name, details]
      end
    end

    def expand_abbreviations!(text)
      TXT_EXPANSIONS.each { |expansion| text.gsub!(*expansion) }
      text
    end

    def to_ssml
      SsmlBuilder.build_ssml do |ssml|
        yield(ssml)
      end.to_xml
    end
  end
end
