# frozen_string_literal: true

require 'ruby/openai'

module Twib
  class Advice
    PROMPT_BASE = <<~TEXT
      Forecast: Thunderstorms. Change of precipitation is 100%. Winds 15 to 20 miles per hour with gusts up to 50 miles per hour.
      Advice: Welp, it's going to be a wet and windy one! Stay indoors or slap on your slicker.

      Forecast: Partly sunny, with a high near 78. Light and variable wind becoming east 5 to 9 mph in the afternoon.
      Advice: You owe it to yourself to outdoors today and play. It's gorgeous out.

      Forecast: Partly cloudy, with a low around 10. Southwest wind 7 to 9 mph, with gusts as high as 18 mph.
      Advice: Bundle up, it's frigid out there! Maybe soup for dinner? Mmmmm…soup.

      Forecast: A chance of rain and snow showers before 10am, then a slight chance of rain between 10am and 4pm. Cloudy, with a high near 41. North wind around 7 miles per hour. Chance of precipitation is 20 percent.
      Advice: Will it be wet? Hard to say. A good day to practice living in the moment.
    TEXT

    OPENAI_PARAMS = {
      temperature: 0.5,
      max_tokens: 64,
      top_p: 1,
      frequency_penalty: 0.5,
      presence_penalty: 0.2,
      stop: ["\n"]
    }.freeze

    OPENAI_ENGINE = 'davinci'

    attr_reader :forecast

    def initialize(forecast)
      @forecast = forecast
    end

    def text
      if openai_response.has_key?('error')
        puts "OPENAI ERROR: #{openai_response}"
        return ''
      end

      openai_response.dig('choices', 0, 'text').strip
    end

    private

    def openai_response
      @_openai_response ||= openai_client.completions(
        engine: OPENAI_ENGINE,
        parameters: { **OPENAI_PARAMS, prompt: prompt(forecast) }
      )
    end

    def prompt(forecast)
      <<~TEXT.strip
        #{PROMPT_BASE}
        Forecast: #{forecast}
        Advice:
      TEXT
    end

    def openai_client
      @_openai_client ||= ::OpenAI::Client.new
    end
  end
end
