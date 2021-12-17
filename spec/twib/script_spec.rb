# frozen_string_literal: true

RSpec.describe Twib::Script do
  describe '.complete_ssmls' do
    let(:advice_text) { " It's glorious out there." }
    let(:advice_double) do
      object_double(Twib::Advice.new(''), text: advice_text)
    end

    let(:forecast_data) do
      JSON.parse(
        File.read('spec/fixtures/nws_response.json')
      )
    end

    let(:periods_count) { described_class::FORECAST_PERIODS_COUNT }

    let(:result) { described_class.complete_ssmls }
    let(:intro_result) { result[0] }
    let(:forecast_result) { result[1, periods_count] }
    let(:credits_result) { result[1 + periods_count] }
    let(:sign_off_result) { result[2 + periods_count] }

    before do
      allow(Twib::Advice).to receive(:new)
        .and_return(advice_double)
      allow(Twib::Forecast).to receive(:data)
        .and_return(forecast_data)
    end

    it 'contains all the expected ssmls' do
      expect(result.length).to be(3 + periods_count)

      xml_header = Nokogiri::XML::Builder.new.to_xml
      expect(result).to all(start_with(xml_header))
    end

    context 'when building the intro ssml' do
      it 'includes the canned intro text' do
        expect(intro_result).to include(
          described_class.intro_text
        )
      end

      it 'includes the advice text' do
        expect(intro_result).to include(advice_text)
      end
    end

    context 'when building the forecast ssmls' do
      it 'includes the forecast text' do
        expect(forecast_result[0]).to include(
          'Mostly clear, with a low around 40.'
        )
      end

      it 'expands abbreviations in the forecast ssmls' do
        expect(forecast_result[0]).to include(
          'West wind around 12 miles per hour.'
        )
      end
    end

    context 'when building the credits ssml' do
      it 'includes the credits text' do
        expect(credits_result).to include(
          described_class::CREDITS_TEXT
        )
      end
    end

    context 'when building the sign off ssml' do
      it 'includes the sign off ss' do
        expect(sign_off_result).to include(
          described_class::SIGN_OFF_TEXT
        )
      end
    end
  end
end
