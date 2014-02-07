# encoding: utf-8
class LinkPreviewParser
  require 'fastimage'
  require 'addressable/uri'
  require 'link_thumbnailer'
  require 'rubygems'
  require 'readability'
  require 'open-uri'
  
  def self.parse(url)

    page_info = linktumbnailer_gem(url)

    page_info[:images] = (page_info[:images] + readability_gem(url) + home_made(url)).uniq


    page_info[:images] = page_info[:images].compact # Removes empty entries from array
    page_info[:images] = page_info[:images].collect{ |image| URI::escape(image).to_s } # Do something

    page_info[:images] = page_info[:images].collect do |image| # Ensures right url
      parsed = Addressable::URI.parse(image)
      if parsed.scheme.nil? && parsed.host.nil?
        "http://" + Addressable::URI.parse(url).host + parsed.path + parsed.omit(:scheme, :host, :path)
      elsif parsed.scheme.nil? && parsed.host
        "http://" + parsed.host + parsed.path + parsed.omit(:scheme, :host, :path)
      else
        image
      end
    end

    page_info[:images] = page_info[:images].collect{ |image| Addressable::URI.parse(image).normalize.to_s } # Do something

    page_info[:images].delete_if{|image| FastImage.type(image) == :gif rescue nil } # Removes gifs because I think its mostly crappy load-images

    # Size

    images_and_sizes = Hash.new

    page_info[:images].each do |images|
        # begin # ignores error with asos.com
        images_and_sizes[images] = FastImage.size(images) rescue nil
        # rescue URI::InvalidComponentError
        #     next
        # end
    end

    images_and_sizes.delete_if do |images, size| 
        if size && size.any?{ |i| i > 200 } && size.all?{ |i| i > 50 }
            false
        else
            true
        end
    end

    images_and_sizes = images_and_sizes.sort_by{ |k, v| v[0] * v[1] }.reverse

    page_info[:images] = images_and_sizes.map{ |k, v| k }

    # END

    return page_info

  end

  def self.linktumbnailer_gem(url)

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

    source = open(url).read
    body = Readability::Document.new(source, :remove_empty_nodes => false, :tags => %w[img], :attributes => %w[src], :ignore_image_format => ["gif"], :min_image_height => 200)

    page_info = {}
    page_info[:title] = body.title
    page_info[:url] = url
    page_info[:images] = body.images

    # object = LinkThumbnailer.generate(url)
    
    # if object.images.size > 1
    #     page_info[:images] = page_info[:images] + object.images.collect{ |i| i.source_url.to_s }
    # else
    #     page_info[:images] = page_info[:images] << object.images[0][:source_url]
    # end

    return page_info[:images]

    # END RELY ON READABILITY

  end

  def self.home_made(url)

    url = Addressable::URI.parse(url).normalize.to_s

    doc = Nokogiri::HTML(open(url))

    page_info = {}

    # Find all images based on size if possible
    # if doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }.empty?
      page_info[:images] = doc.css('body img').map{ |node| node['src'] }
    # else
    #   page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}.map{ |node| node['src'] }
    # end

    return page_info[:images][1..100]
  end

  def self.price(url)
    
    url = Addressable::URI.parse(url).normalize.to_s
    doc = Nokogiri::HTML(open(url))

    prices = doc.at('body').xpath("//*[@*[contains(., 'price')]]").map{|i| i.inner_text.strip.match(/(?<=\p{Z}|^)(([A-Z]{3}|\p{Sc})(\p{Z})?)?(([1-9]{1}(\d{1,2})?(\.\d{3})*(\,\d{2})?)|([1-9]{1}(\d{1,2})?(\,\d{3})*(\.\d{2})?))((\p{Z})?([A-Z]{3}|\p{Sc}))?(?=\p{Z}|$)/m).to_a[0] }.compact

    header_tag = doc.at('body').xpath("//html/header").map{|i| i.inner_text.strip.match(/(?<=\p{Z}|^)(([A-Z]{3}|\p{Sc})(\p{Z})?)?(([1-9]{1}(\d{1,2})?(\.\d{3})*(\,\d{2})?)|([1-9]{1}(\d{1,2})?(\,\d{3})*(\.\d{2})?))((\p{Z})?([A-Z]{3}|\p{Sc}))?(?=\p{Z}|$)/m).to_a[0] }

    price = (prices - header_tag)[0].to_s
      

  end

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}[0]['src']

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}['src'].map(&:inspect).join(', ')

    # page_info[:img] = doc.css('body img')[0]['src']

    # if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    #   page_info[:img] = URI::join(url, page_info[:img]).to_s # Sets the absoloute reference
    # end
end