class LinkPreviewParser
  def self.parse(url)
    doc = Nokogiri::HTML(open(url))
    page_info = {}
    page_info[:title] = doc.css('title').text
    page_info[:url] = url
    page_info[:img] = doc.css('img').select{|img| img[:width].to_i > 200}[0]['src']
    return page_info
  end
end