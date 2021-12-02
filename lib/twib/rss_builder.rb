# frozen_string_literal: true

module Twib
  class RssBuilder < Nokogiri::XML::Builder
    def episode_item(data)
      item do |rss|
        rss.title data[:title]
        rss.description do
          rss.cdata(data[:description])
        end
        rss['content'].encoded do
          rss.cdata(data[:description])
        end
        rss['itunes'].episode data[:number]
        rss.pubDate data[:pub_date]
        rss['itunes'].duration data[:duration]
        rss['itunes'].author data[:author]

        rss['itunes'].image(href: data[:image_url])
        rss.enclosure(
          url: data[:enclosure][:url],
          length: data[:enclosure][:length],
          type: data[:enclosure][:type]
        )
        rss.guid data[:guid]
      end
    end

    def podcast_root
      rss(
        'xmlns:itunes' => 'http://www.itunes.com/dtds/podcast-1.0.dtd',
        'xmlns:content' => 'http://purl.org/rss/1.0/modules/content/',
        'xmlns:atom' => 'http://www.w3.org/2005/Atom',
        'version' => '2.0'
      ) do |rss|
        rss.channel_root { yield(rss) }
      end
    end

    def channel_root
      channel do |rss|
        rss.title PODCAST[:title]
        rss.description do
          rss.cdata(PODCAST[:description])
        end
        rss['itunes'].summary PODCAST[:description]
        rss.managingEditor PODCAST[:editor]
        rss.copyright PODCAST[:owner][:name]
        rss.link PODCAST_HOMEPAGE
        rss['itunes'].owner do |owner|
          owner.email PODCAST[:owner][:email]
          owner.name PODCAST[:owner][:name]
        end
        rss['itunes'].author PODCAST[:owner][:name]
        rss.language PODCAST[:language]
        PODCAST[:categories].each do |cat, subcats|
          rss['itunes'].category(text: cat) do
            subcats.each do |subcat|
              rss['itunes'].category(text: subcat)
            end
          end
        end
        rss['itunes'].image(href: PODCAST[:image][:url])
        rss.image do
          rss.url PODCAST[:image][:url]
          rss.link PODCAST[:image][:link]
          rss.title PODCAST[:image][:title]
        end
        rss['itunes'].explicit 'no'
        rss['atom'].link(
          href: Podcast.feed_url,
          rel: 'self',
          type: 'application/rss+xml'
        )
        yield(rss)
      end
    end
  end
end
