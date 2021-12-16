# frozen_string_literal: true

RSpec.describe Twib::SpeechSynth do
  let(:polly_client) { Aws::Polly::Client.new(stub_responses: true) }

  let(:ssmls) do
    3.times.map do |n|
      <<~SSML
        <?xml version="1.0"?>
        <speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="en-US">Number #{n + 1}</speak>
      SSML
    end
  end

  before do
    stub_const('Twib::POLLY_CLIENT', polly_client)
    allow(Twib::Sox).to receive(:concatenate)
    polly_client.stub_responses(
      :describe_voices,
      {
        voices: [
          { id: 'Emma', language_code: 'en-GB' },
          { id: 'Ruben', language_code: 'nl-NL' }
        ]
      }
    )
  end

  describe '.bulk_synthesize' do
    it 'selects a Polly neural English-speaking voice at random' do
      expect(polly_client).to receive(:synthesize_speech)
        .exactly(ssmls.count).times
        .with(hash_including(voice_id: 'Emma'))

      described_class.bulk_synthesize(ssmls)
    end

    it 'synthesizes each of the input ssmls' do
      ssmls.each do |ssml|
        expect(polly_client).to receive(:synthesize_speech)
          .with(hash_including(text: ssml))
      end

      described_class.bulk_synthesize(ssmls)
    end

    it 'stores the speech audio in temporary files' do
      ssmls.count.times.each do |n|
        expect(polly_client).to receive(:synthesize_speech) do |params|
          expect(params[:response_target]).to end_with(
            "raw_speech_#{n}.mp3"
          )
        end
      end

      described_class.bulk_synthesize(ssmls)
    end
  end
end
