# frozen_string_literal: true

RSpec.describe Twib::RssBuilder do
  describe '#podcast_root' do
    let(:result) do
      described_class.new do
        podcast_root do |rss|
          rss.testFoo 'bar'
        end
      end
    end

    describe 'the rss node' do
      let(:rss_node) { result.doc.xpath('rss').first }

      it 'is the root of the document' do
        expect(rss_node).to eq(result.doc.root)
      end

      it 'has the correct XML version' do
        expect(rss_node.attributes['version'].value).to eq('2.0')
      end
    end

    describe 'the channel node' do
      let(:channel_node) { result.doc.xpath('rss/channel').first }

      it 'is nested under the rss node' do
        expect(channel_node).to eq(result.doc.root.children.first)
      end

      it 'has the custom node passed into the block' do
        expect_child_element(channel_node, name: 'testFoo')
      end

      it 'has a title node' do
        expect_child_element(channel_node, name: 'title')
      end

      it 'has a description node' do
        expect_child_element(channel_node, name: 'description')
      end

      it 'has an itunes summary node' do
        expect_child_element(
          channel_node, name: 'summary', namespace: 'itunes'
        )
      end

      it 'has a managingEditor node' do
        expect_child_element(channel_node, name: 'managingEditor')
      end

      it 'has a copyright node' do
        expect_child_element(channel_node, name: 'copyright')
      end

      it 'has a link node' do
        expect_child_element(
          channel_node,
          name: 'link',
          text: match(URI::DEFAULT_PARSER.make_regexp)
        )
      end

      it 'has an itunes owner node' do
        expect_child_element(
          channel_node, name: 'owner', namespace: 'itunes'
        )
      end

      it 'has an itunes author node' do
        expect_child_element(
          channel_node, name: 'author', namespace: 'itunes'
        )
      end

      it 'has a language node' do
        expect_child_element(channel_node, name: 'language')
      end

      it 'has two itunes category nodes' do
        expect_child_element(
          channel_node,
          name: 'category',
          namespace: 'itunes',
          text: ''
        )
      end

      it 'has an itunes image node' do
        expect_child_element(
          channel_node,
          name: 'image',
          namespace: 'itunes',
          text: '' # URL in href attribute
        )
      end

      it 'has an image node' do
        expect_child_element(channel_node, name: 'image')
      end

      it 'has an itunes explicit element' do
        expect_child_element(
          channel_node,
          name: 'explicit',
          namespace: 'itunes',
          text: 'no'
        )
      end

      it 'has an atom link element' do
        expect_child_element(
          channel_node,
          name: 'link',
          namespace: 'atom',
          text: ''
        )
      end
    end
  end

  def expect_child_element(element, name:, text: be_present, namespace: nil)
    expect(element.children.to_a).to include(
      an_object_having_attributes(
        text: text,
        name: name,
        namespace: namespace && having_attributes(prefix: namespace)
      )
    )
  end
end
