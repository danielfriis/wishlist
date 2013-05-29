class LinkPreviewParser
  def self.parse(url)
  	sleep 4
  	base_url = baseurl = URI::join(url, "/").to_s

    doc = Nokogiri::HTML(open(url))
    page_info = {}
    page_info[:title] = doc.css('title').text
    page_info[:url] = url
    page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}[0]['src']
    if page_info[:img].starts_with?("/") # Checks if src is a relative reference
    	page_info[:img] = URI::join(url, page_info[:img]).to_s # Sets the absoloute reference
    end
    return page_info
  end
end