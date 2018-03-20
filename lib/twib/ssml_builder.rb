module Twib
  class SsmlBuilder < Nokogiri::XML::Builder
    def self.build_ssml
      new do |ssml|
        ssml.speak_root { yield(ssml) }
      end
    end

    def pause(seconds)
      self.break(time: "#{seconds.to_f}s")
    end

    def speak_root
      speak(
        xmlns: "http://www.w3.org/2001/10/synthesis",
        version: "1.0",
        "xml:lang" => "en-US",
        ) { yield }
    end
  end

  class Document < Nokogiri::XML::Document
  end
end
