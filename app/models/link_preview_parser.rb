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

    page_info[:price] = price(url) rescue nil

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
    
    # Normalize URI
    url = Addressable::URI.parse(url).normalize.to_s

    # Open page
    doc = Nokogiri::HTML(open(url))

    # Get arrary of iso_codes and symbols
    currencies_string = Money::Currency.table.collect{|k,h| [h[:iso_code],h[:symbol],h[:alternate_symbols]]}.flatten.map { |c| Regexp.escape(c) unless c.nil? }.join('|')
    currencies_string << "|kr."
    # Construct regex
    price_regex = /(?<=\p{Z}|^)((#{currencies_string})(\p{Z})?)?(([1-9]{1}(\d{1,2})?(\.\d{3})*(\,\d{2})?)|([1-9]{1}(\d{1,2})?(\,\d{3})*(\.\d{2})?))((\p{Z})?(#{currencies_string}))?(?=\p{Z}|$)/m

    # Retract price based on meta data
    itemprop_price = doc.at('body').xpath("//*[@itemprop='price']").map{|i| i.inner_text.strip.gsub(/\t|\r|\n/," ").match(price_regex).to_a[0] }.compact
    itemprop_price = (itemprop_price.kind_of?(Array) ? itemprop_price[0] : itemprop_price)

    itemprop_curr = doc.at('body').xpath("//*[@itemprop='currency']").inner_text.strip
    itemprop_curr = (itemprop_curr.kind_of?(Array) ? itemprop_curr[0] : itemprop_curr)

    if itemprop_curr.present? && itemprop_price.present?
      price = itemprop_price + " " + itemprop_curr
    elsif itemprop_curr.blank? && itemprop_price.present?
      price = itemprop_price
    else
      # Retract prices based on classes containing "price" and a regex
      # prices = doc.at('body').xpath("//*[@*[contains(., 'price')]]").map{|i| i.inner_text.strip.match(/(?<=\p{Z}|^)(([A-Z]{3}|\p{Sc})(\p{Z})?)?(([1-9]{1}(\d{1,2})?(\.\d{3})*(\,\d{2})?)|([1-9]{1}(\d{1,2})?(\,\d{3})*(\.\d{2})?))((\p{Z})?([A-Z]{3}|\p{Sc}))?(?=\p{Z}|$)/m).to_a[0] }.compact
      prices = doc.at('body').xpath("//*[@*[contains(., 'price')]]").map{|i| i.inner_text.strip.gsub(/\t|\r|\n/," ").match(price_regex).to_a[0] }.compact

      # This is to exclude the 'basket'
      header_tag = doc.at('body').xpath("//html/header").map{|i| i.inner_text.strip.gsub(/\t|\r|\n/," ").match(price_regex).to_a[0] }

      # Get the first price which is not in the header tag
      price = (prices - header_tag)[0]

    end

    # Replace symbols for the monetize gem to work properply
    # price.gsub('$','USD').gsub('€','EUR').gsub('£','GBP').to_s unless price.nil?
    currencies = {'$' => 'USD','€' => 'EUR','kr' => 'DKK','kr.' => 'DKK',',-' => 'DKK', '£' => 'GBP'}
    re = Regexp.new(currencies.keys.map { |x| Regexp.escape(x) }.join('|'))
    price.gsub!(re, currencies) unless price.nil?

    # Money gem fucks up when parsing 2.000 DKK. Becomes 2,00 DKK
    tousands_dot = /((\.\d{3})(?=\p{Z}|$|\w))/
    tousands_comma = /((\,\d{3})(?=\p{Z}|$|\w))/

    tousands_dot_found = price.match(tousands_dot)[0] rescue nil
    tousands_comma_found = price.match(tousands_dot)[0] rescue nil

    if tousands_dot_found.present?
      tousands_dot_found_fix = tousands_dot_found + ",00"
      price.gsub!(tousands_dot_found,tousands_dot_found_fix)
    elsif tousands_comma_found.present?
      tousands_comma_found_fix = tousands_comma_found + ".00"
      price.gsub!(tousands_comma_found,tousands_comma_found_fix)
    end

    return price

  end

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}[0]['src']

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}['src'].map(&:inspect).join(', ')

    # page_info[:img] = doc.css('body img')[0]['src']

    # if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    #   page_info[:img] = URI::join(url, page_info[:img]).to_s # Sets the absoloute reference
    # end
end