class LinkPreviewParser
  def self.parse(url)
    require 'fastimage'

  	base_url = baseurl = URI::join(url, "/").to_s

    doc = Nokogiri::HTML(open(url))

    page_info = {}
    page_info[:title] = doc.css('title').text
    page_info[:url] = url

    # Find all images based on size if possible
    # if doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }.empty?
      page_info[:img] = doc.css('body img').map{ |node| node['src'] }
    # else
    #   page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }
    # end

    page_info[:img] = page_info[:img].compact # Removes empty entries from array
    page_info[:img].delete_if{|img| img.ends_with? ".gif" } # Removes gifs because I think its mostly crappy load-images

    if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    	page_info[:img] = page_info[:img].collect{ |img| URI::join(url, URI.escape(img)).to_s} # Sets the absoloute reference
    end

    imgs_and_sizes = Hash.new

    page_info[:img].each do |img|
        begin # ignores error with asos.com
        imgs_and_sizes[img] = FastImage.size(URI.escape(img))
        rescue URI::InvalidComponentError
            next
        end
    end

    imgs_and_sizes.delete_if do |img, size| 
        if size && size.any?{ |i| i > 200 } && size.all? { |i| i > 150 }
            false
        else
            true
        end
    end

    imgs_and_sizes = imgs_and_sizes.sort_by{ |k, v| v[0] * v[1] }.reverse

    page_info[:img] = imgs_and_sizes.map{ |k, v| k }


    return page_info
  end

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}[0]['src']

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}['src'].map(&:inspect).join(', ')

    # page_info[:img] = doc.css('body img')[0]['src']

    # if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    #   page_info[:img] = URI::join(url, page_info[:img]).to_s # Sets the absoloute reference
    # end
end