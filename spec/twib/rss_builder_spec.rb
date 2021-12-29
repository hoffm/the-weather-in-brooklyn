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

    describe 'the rss element' do
      let(:rss_node) { result.doc.xpath('rss').first }

      it 'is the root of the document' do
        expect(rss_node).to eq(result.doc.root)
      end

      it 'has the correct XML version' do
        expect(rss_node.attributes['version'].value).to eq('2.0')
      end
    end

    describe 'the channel element' do
      let(:channel_element) { result.doc.xpath('rss/channel').first }

      it 'is nested under the rss element' do
        expect(channel_element).to eq(result.doc.root.children.first)
      end

      it 'has the custom element passed into the block' do
        expect_child_element(channel_element, name: 'testFoo')
      end

      it 'has a title element' do
        expect_child_element(channel_element, name: 'title')
      end

      it 'has a description element' do
        expect_child_element(channel_element, name: 'description')
      end

      describe 'description element' do
        let(:description_element) do
          channel_element.xpath('description').first
        end

        it 'has CDATA' do
          expect_child_element(
            description_element,
            name: '#cdata-section'
          )
        end
      end

      it 'has an itunes summary element' do
        expect_child_element(
          channel_element, name: 'summary', namespace: 'itunes'
        )
      end

      it 'has a managingEditor element' do
        expect_child_element(channel_element, name: 'managingEditor')
      end

      it 'has a copyright element' do
        expect_child_element(channel_element, name: 'copyright')
      end

      it 'has a link element' do
        expect_child_element(
          channel_element,
          name: 'link',
          text: match(URI::DEFAULT_PARSER.make_regexp)
        )
      end

      it 'has an itunes owner element' do
        expect_child_element(
          channel_element, name: 'owner', namespace: 'itunes'
        )
      end

      describe 'owner element' do
        let(:owner_element) do
          channel_element.xpath('itunes:owner').first
        end

        it 'has an email child element' do
          expect_child_element(
            owner_element, name: 'email', namespace: 'itunes'
          )
        end

        it 'has a name child element' do
          expect_child_element(
            owner_element, name: 'name', namespace: 'itunes'
          )
        end
      end

      it 'has an itunes author element' do
        expect_child_element(
          channel_element, name: 'author', namespace: 'itunes'
        )
      end

      it 'has a language element' do
        expect_child_element(channel_element, name: 'language')
      end

      it 'has two itunes category elements' do
        expect_child_element(
          channel_element,
          name: 'category',
          namespace: 'itunes',
          text: '',
          count: 2
        )
      end

      it 'has an itunes image element' do
        expect_child_element(
          channel_element,
          name: 'image',
          namespace: 'itunes',
          text: ''
        )
      end

      describe 'itunes image element' do
        let(:image_element) do
          channel_element.xpath('itunes:image').first
        end

        it 'has an href attribute with a url' do
          href = image_element.attributes['href'].value
          expect(href).to match(URI::DEFAULT_PARSER.make_regexp)
        end
      end

      it 'has an image element' do
        expect_child_element(channel_element, name: 'image')
      end

      describe 'image element' do
        let(:image_element) do
          channel_element.xpath('image').first
        end

        it 'has a url child element' do
          expect_child_element(
            image_element,
            name: 'url',
            text: match(URI::DEFAULT_PARSER.make_regexp)
          )
        end

        it 'has a link child element' do
          expect_child_element(
            image_element,
            name: 'link',
            text: match(URI::DEFAULT_PARSER.make_regexp)
          )
        end

        it 'has a title child element' do
          expect_child_element(image_element, name: 'title')
        end
      end

      it 'has an itunes explicit element' do
        expect_child_element(
          channel_element,
          name: 'explicit',
          namespace: 'itunes',
          text: 'no'
        )
      end

      it 'has an atom link element' do
        expect_child_element(
          channel_element,
          name: 'link',
          namespace: 'atom',
          text: ''
        )
      end

      describe 'atom link element' do
        let(:link_element) do
          channel_element.xpath('atom:link').first
        end

        it 'has an href attribute with a url' do
          href = link_element.attributes['href'].value
          expect(href).to match(URI::DEFAULT_PARSER.make_regexp)
        end

        it 'has an rel attribute with self as value' do
          rel = link_element.attributes['rel'].value
          expect(rel).to eq('self')
        end

        it 'has an type attribute with rss+xml as value' do
          type = link_element.attributes['type'].value
          expect(type).to eq('application/rss+xml')
        end
      end
    end
  end

  describe '#episode_item' do
    let(:episode_data) do
      {
        number: 42,
        title: 'title',
        enclosure: {
          url: 'audio url',
          length: 100,
          type: 'audio/mpeg'
        },
        pub_date: 'pub date',
        duration: 100,
        subtitle: 'sub title',
        description: 'description',
        language: 'en-us',
        image_url: 'image url',
        guid: 'guid',
        author: 'author'
      }
    end

    let(:result) do
      described_class.new do
        podcast_root do |rss|
          rss.episode_item(episode_data)
        end
      end
    end

    let(:episode_element) do
      result.doc.xpath('rss/channel/item').first
    end

    it 'produces an item element' do
      expect(episode_element.name).to eq('item')
    end

    describe 'item element' do
      it 'has a title element' do
        expect_child_element(
          episode_element,
          name: 'title',
          text: episode_data[:title]
        )
      end

      it 'has a description element' do
        expect_child_element(
          episode_element,
          name: 'description',
          text: episode_data[:description]
        )
      end

      describe 'description element' do
        let(:description_element) do
          episode_element.xpath('description').first
        end

        it 'has CDATA' do
          expect_child_element(
            description_element,
            name: '#cdata-section',
            text: episode_data[:description]
          )
        end
      end

      it 'has a content encoded element' do
        expect_child_element(
          episode_element,
          name: 'encoded',
          namespace: 'content'
        )
      end

      describe 'content encoded element' do
        let(:encoded_element) do
          episode_element.xpath('content:encoded').first
        end

        it 'has CDATA' do
          expect_child_element(
            encoded_element,
            name: '#cdata-section',
            text: episode_data[:description]
          )
        end
      end

      it 'has an itunes episode element' do
        expect_child_element(
          episode_element,
          name: 'episode',
          text: episode_data[:number].to_s,
          namespace: 'itunes'
        )
      end

      it 'has a pubDate element' do
        expect_child_element(
          episode_element,
          name: 'pubDate',
          text: episode_data[:pub_date]
        )
      end

      it 'has an itunes duration element' do
        expect_child_element(
          episode_element,
          name: 'duration',
          text: episode_data[:duration].to_s,
          namespace: 'itunes'
        )
      end

      it 'has an itunes author element' do
        expect_child_element(
          episode_element,
          name: 'author',
          text: episode_data[:author],
          namespace: 'itunes'
        )
      end

      it 'has an itunes image element' do
        expect_child_element(
          episode_element,
          name: 'image',
          text: '',
          namespace: 'itunes'
        )
      end

      describe 'itunes image element' do
        let(:image_element) do
          episode_element.xpath('itunes:image').first
        end

        it 'has an href attribute' do
          href = image_element.attributes['href'].value
          expect(href).to eq(episode_data[:image_url])
        end
      end

      it 'has an enclosure element' do
        expect_child_element(
          episode_element,
          name: 'enclosure',
          text: ''
        )
      end

      describe 'enclosure element' do
        let(:enclosure_element) do
          episode_element.xpath('enclosure').first
        end

        let(:enclosure_data) { episode_data[:enclosure] }

        it 'has a url attribute' do
          url = enclosure_element.attributes['url'].value
          expect(url).to eq(enclosure_data[:url])
        end

        it 'has a length attribute' do
          length = enclosure_element.attributes['length'].value
          expect(length).to eq(enclosure_data[:length].to_s)
        end

        it 'has a type attribute' do
          type = enclosure_element.attributes['type'].value
          expect(type).to eq(enclosure_data[:type])
        end
      end

      it 'has a guid element' do
        expect_child_element(
          episode_element,
          name: 'guid',
          text: episode_data[:guid]
        )
      end
    end
  end

  def expect_child_element(element, **opts)
    text = opts.key?(:text) ? opts[:text] : be_present
    namespace = opts[:namespace] &&
                having_attributes(prefix: opts[:namespace])
    count = opts[:count] || 1

    expect(element.children.to_a).to include(
      an_object_having_attributes(
        text: text,
        name: opts[:name],
        namespace: namespace
      )
    ).exactly(count).times
  end
end
