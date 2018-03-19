class SsmlBuilder < Nokogiri::XML::Builder
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
