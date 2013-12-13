class LinkPreviewParser
  
  def self.parse(url)

    page_info = linktumbnailer_gem(url)

    page_info[:images] = (page_info[:images] + readability_gem(url) + home_made(url)).uniq

    return page_info

  end

  def self.linktumbnailer_gem(url)
    require 'link_thumbnailer'

    object = LinkThumbnailer.generate(url)

    page_info = {}
    page_info[:title] = object.title
    page_info[:url] = url
    page_info[:images] = Array.new
    
    if object.images.size > 1
        page_info[:images] = page_info[:images] + object.images.collect{ |i| i.source_url.to_s }
    else
        page_info[:images] = page_info[:images] << object.images[0][:source_url]
    end

    return page_info

  end

  
  def self.readability_gem(url)
    # RELY ON READABILITY GEM
    require 'rubygems'
    require 'readability'
    require 'open-uri'

    source = open(url).read
    body = Readability::Document.new(source, :remove_empty_nodes => false, :tags => %w[img], :attributes => %w[src], :ignore_image_format => ["gif"], :min_image_height => 200)

    page_info = {}
    page_info[:title] = body.title
    page_info[:url] = url
    page_info[:images] = body.images

    object = LinkThumbnailer.generate(url)
    
    if object.images.size > 1
        page_info[:images] = page_info[:images] + object.images.collect{ |i| i.source_url.to_s }
    else
        page_info[:images] = page_info[:images] << object.images[0][:source_url]
    end

    return page_info[:images]

    # END RELY ON READABILITY

  end

  def self.home_made(url)
    require 'fastimage'
    require 'addressable/uri'

    url = Addressable::URI.parse(url).normalize.to_s

  	base_url = baseurl = URI::join(url, "/").to_s

    doc = Nokogiri::HTML(open(url))

    page_info = {}

    # Find all images based on size if possible
    # if doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }.empty?
      page_info[:images] = doc.css('body img').map{ |node| node['src'] }
    # else
    #   page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }
    # end

    page_info[:images] = page_info[:images].compact # Removes empty entries from array
    page_info[:images].delete_if{|images| images.ends_with? ".gif" } # Removes gifs because I think its mostly crappy load-images

    if page_info[:images][0].starts_with?("/") # Checks if src is a relative reference
    	page_info[:images] = page_info[:images].collect{ |images| URI::join(url, URI::escape(images)).to_s} # Sets the absoloute reference
    end

    page_info[:images].collect{ |images| Addressable::URI.parse(images).normalize.to_s }

    images_and_sizes = Hash.new

    page_info[:images].each do |images|
        begin # ignores error with asos.com
        images_and_sizes[images] = FastImage.size(images) rescue nil
        rescue URI::InvalidComponentError
            next
        end
    end

    images_and_sizes.delete_if do |images, size| 
        if size && size.any?{ |i| i > 200 } && size.all? { |i| i > 50 }
            false
        else
            true
        end
    end

    images_and_sizes = images_and_sizes.sort_by{ |k, v| v[0] * v[1] }.reverse

    page_info[:images] = images_and_sizes.map{ |k, v| k }


    return page_info[:images]
  end

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}[0]['src']

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}['src'].map(&:inspect).join(', ')

    # page_info[:img] = doc.css('body img')[0]['src']

    # if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    #   page_info[:img] = URI::join(url, page_info[:img]).to_s # Sets the absoloute reference
    # end
end