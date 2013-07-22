class LinkPreviewParser
  def self.parse(url)
  	base_url = baseurl = URI::join(url, "/").to_s

    doc = Nokogiri::HTML(open(url))

    page_info = {}
    page_info[:title] = doc.css('title').text
    page_info[:url] = url

    # Find all images based on size if possible
    if doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }.empty?
      page_info[:img] = doc.css('body img').map{ |node| node['src'] }
    else
      page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }
    end

    page_info[:img] = page_info[:img].compact # Removes empty entries from array
    page_info[:img].delete_if{|img| img.ends_with? ".gif" } # Removes gifs because I think its mostly crappy load-images

    if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    	page_info[:img] = page_info[:img].collect{ |img| URI::join(url, img).to_s} # Sets the absoloute reference
    end

    return page_info
  end

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}[0]['src']

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}['src'].map(&:inspect).join(', ')

    # page_info[:img] = doc.css('body img')[0]['src']

    # if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    #   page_info[:img] = URI::join(url, page_info[:img]).to_s # Sets the absoloute reference
    # end
end