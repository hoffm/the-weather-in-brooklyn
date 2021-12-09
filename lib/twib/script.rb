# frozen_string_literal: true

module Twib
  module Script
    module_function

    TXT_EXPANSIONS = {
      'mph' => 'miles per hour',
      '%' => ' percent'
    }.freeze

    CREDITS_TEXT = <<~TEXT
      The Weather in Brooklyn is an automated podcast by Michael Hoffman.
      Music by Jascha Hoffman.
      Audio logo by Nate Heller.
      Podcast photograph by Alex Simpson.
    TEXT

    def complete_ssmls
      [
        intro_ssml,
        *forecast_ssmls,
        credits_ssml,
        sign_off_ssml
      ]
    end

    def forecast_ssmls
      current_forecast.map do |name, details|
        period_ssml(name, details)
      end
    end

    def intro_ssml
      to_ssml do |ssml|
        ssml.pause 5
        ssml.text intro_text
        ssml.pause 1
        ssml.text advice_text
        ssml.pause 1
        ssml.text "Here's your forecast."
        ssml.pause 2
      end
    end

    def period_ssml(name, details)
      to_ssml do |ssml|
        ssml.text "#{name}. #{details}"
        ssml.pause 5
      end
    end

    def credits_ssml
      to_ssml do |ssml|
        ssml.pause 10
        ssml.text CREDITS_TEXT
        ssml.pause 2
      end
    end

    def sign_off_ssml
      to_ssml do |ssml|
        ssml.text 'Have a lovely day.'
        ssml.pause 3
      end
    end

    def current_forecast
      @_current_forecast ||= Forecast.data['periods'].map do |period|
        name = period['name']
        details = expand_abbreviations!(period['detailedForecast'])
        [name, details]
      end.take(2)
    end

    def expand_abbreviations!(text)
      TXT_EXPANSIONS.each { |expansion| text.gsub!(*expansion) }
      text
    end

    def to_ssml(&block)
      SsmlBuilder.build_ssml(&block).to_xml
    end

    def intro_text
      <<~TEXT
        This is The Weather in Brooklyn. Welcome.
        It's #{date_text}.
      TEXT
    end

    def advice_text
      today_forecast_text = current_forecast[0][1]
      Advice.new(today_forecast_text).text
    end

    def date_text
      "#{Time.now.strftime('%A')}, #{Date.today.to_s(:long_ordinal)}"
    end
  end
end
