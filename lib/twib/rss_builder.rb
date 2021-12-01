module Twib
  class RssBuilder < Nokogiri::XML::Builder
    def self.build_podcast_feed
      new do |rss|
        rss.podcast_root do |rss|
          DataUtils.latest_episodes_data.each do |data|
            rss.episode_item(data)
          end
        end
      end
    end

    def episode_item(data)
      data = OpenStruct.new(data)
      enclosure = OpenStruct.new(data.enclosure)

      item do |rss|
        rss.title data.title
        rss.description do
          rss.cdata(data.description)
        end
        rss["content"].encoded do
          rss.cdata(data.description)
        end
        rss["itunes"].episode data.number
        rss.pubDate data.pub_date
        rss["itunes"].duration data.duration
        rss["itunes"].image(href: data.image_url)
        rss.enclosure(
          url: enclosure.url,
          length: enclosure.length,
          type: enclosure.type
        )
      end
    end

    def podcast_root
      rss(
        "xmlns:itunes" => "http://www.itunes.com/dtds/podcast-1.0.dtd",
        "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom",
        "version" => "2.0"
      ) do |rss|
        rss.channel_root { yield(rss) }
      end
    end

    def channel_root
      data = OpenStruct.new(PODCAST)
      channel do |rss|
        rss.title data.title
        rss.description do
          rss.cdata(data.description)
        end
        rss["itunes"].summary data.description
        rss.managingEditor data.editor
        rss.copyright data.owner[:name]
        rss.link data.link
        rss["itunes"].owner do |owner|
          owner.email data.owner[:email]
          owner.name data.owner[:name]
        end
        rss["itunes"].author data.owner[:name]
        rss.language data.language
        data.categories.each do |cat, subcats|
          rss["itunes"].category( text: cat) do
            subcats.each do |subcat|
              rss["itunes"].category( text: subcat )
            end
          end
        end
        rss["itunes"].image(href: data.image[:url])
        rss.image do
          rss.url data.image[:url]
          rss.link data.image[:link]
          rss.title data.image[:title]
        end
        rss["itunes"].explicit "no"
        rss["atom"].link(
          href: data.link,
          rel: "self",
          type: "application/rss+xml",
        )
        yield(rss)
      end
    end
  end
end
