# frozen_string_literal: true

RSpec.describe Twib::SsmlBuilder do
  describe '.build_ssml' do
    let(:document) do
      described_class.build_ssml do |ssml|
        ssml.text 'Hello world!'
      end
    end

    it 'outputs a document beginning with an XML header' do
      xml_header = Nokogiri::XML::Builder.new.to_xml
      expect(document.to_xml).to start_with(xml_header)
    end

    it 'outputs a document with a speak node' do
      expect(document.to_xml).to include(
        '<speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="en-US">Hello world!</speak>'
      )
    end
  end

  describe '#pause' do
    let(:document) do
      described_class.build_ssml do |ssml|
        ssml.text 'Wait for'
        ssml.pause 5
        ssml.text 'it'
      end
    end

    it 'adds a break node of specified duration as a float' do
      expect(document.to_xml).to include(
        'Wait for<break time="5.0s"/>it'
      )
    end
  end
end
