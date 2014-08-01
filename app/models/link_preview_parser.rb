# encoding: utf-8
class LinkPreviewParser
  require 'fastimage'
  require 'addressable/uri'
  require 'open-uri'
  
  def self.parse(url)

    # page_info = linktumbnailer_gem(url)

    # page_info[:images] = (page_info[:images] + readability_gem(url) + home_made(url)).uniq
    # page_info[:images] = (page_info[:images] + home_made(url)).uniq
    # Removed readability gem parsing because it is slow.

    url = Addressable::URI.parse(url).normalize.to_s
    doc = Nokogiri::HTML(open(url))

    page_info = {}
    page_info[:title] = doc.at_css("title").text.strip.gsub(/\r\n|\r|\n/, '')
    page_info[:url] = url
    page_info[:images] = images(url, doc)
    page_info[:price] = price(url, doc) rescue nil

    return page_info

  end

  def self.images(url, doc=nil)
    if doc == nil
      url = Addressable::URI.parse(url).normalize.to_s
      doc = Nokogiri::HTML(open(url))
    end

    page_info = {}

    page_info[:images] = doc.css('body img').map{ |node| node['src'] }
    page_info[:images] << doc.at('body').xpath("//*[@itemprop='image']/@content").map{|i| i.value }.first  rescue nil
    page_info[:images] << doc.at('body').xpath("//*[@itemprop='image']/@src").map{|i| i.value }.first  rescue nil
    page_info[:images] << doc.at('meta[@property="og:image"]')[:content] rescue nil

    page_info[:bad_images] = doc.css('header img').map{ |node| node['src'] } rescue nil
    page_info[:bad_images] << doc.css('footer img').map{ |node| node['src'] } rescue nil
    page_info[:bad_images] << doc.css('nav img').map{ |node| node['src'] } rescue nil

    page_info[:images] = page_info[:images] - page_info[:bad_images].flatten rescue nil

    page_info[:images] = page_info[:images].compact # Removes empty entries from array
    page_info[:images] = page_info[:images].collect{ |image| URI::escape(image).to_s } # Do something

    # Maybe exclude anything from nav and footer and header

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

    # page_info[:images].delete_if{|image| FastImage.type(image) == :gif rescue nil } # Removes gifs because I think its mostly crappy load-images

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
        if size && size.any?{ |i| i > 130 } && size.all?{ |i| i > 50 }
            false
        else
            true
        end
    end

    images_and_sizes = images_and_sizes.sort_by{ |k, v| (v[0] * v[1]) }.reverse

    page_info[:images] = images_and_sizes.map{ |k, v| k }
    
    return page_info[:images][0..100]
  end

  def self.price(url, doc=nil)
    if doc == nil
      url = Addressable::URI.parse(url).normalize.to_s
      doc = Nokogiri::HTML(open(url))
    end
    # Normalize URI
    # url = Addressable::URI.parse(url).normalize.to_s

    # # Open page
    # doc = Nokogiri::HTML(open(url))

    # Get arrary of iso_codes and symbols
    currencies_regex = Regexp.union(Money::Currency.table.collect{|k,h| [h[:iso_code],h[:symbol],h[:alternate_symbols]]}.flatten.compact.reject!{ |c| c.empty? } << "|kr.")
    # Construct regex
    price_regex = /(?<=\p{Z}|^)((#{currencies_regex})(\p{Z})?)?(([1-9]{1}(\d{1,2})?((\.)?\d{3})*(\,\d{2})?)|([1-9]{1}(\d{1,2})?((\,)?\d{3})*(\.\d{2})?))((\p{Z})?(#{currencies_regex}))?(?=\p{Z}|$)/m

    # Retract price based on meta data
    itemprop_price = doc.at('body').xpath("//*[@itemprop='price']").map{|i| [i.inner_text.strip.gsub(/\s+|\t|\r|\n/," ").match(price_regex).to_a[0], i[:content]] }.flatten.uniq.compact
    itemprop_price = (itemprop_price.kind_of?(Array) ? itemprop_price[0] : itemprop_price)

    # itemprop_curr_pre = doc.at('body').xpath("//*[@itemprop='currency']")
    itemprop_curr = doc.at('body').xpath("//*[contains(translate(@itemprop,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), 'currency')]").map{|i| [i.inner_text.strip, i[:content]] }.flatten.uniq.compact.reject(&:empty?)
    itemprop_curr = (itemprop_curr.kind_of?(Array) ? itemprop_curr[0] : itemprop_curr)

    if itemprop_curr.present? && itemprop_price.present?
      price = itemprop_price + " " + itemprop_curr
    elsif itemprop_curr.blank? && itemprop_price.present?
      price = itemprop_price
    else
      # Retract prices based on classes containing "price" and a regex
      # "translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" is to makes nokogiri case in-sentive. Replaces "."
      prices = doc.at('body').xpath("//*[@*[contains(translate(.,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'), 'price')]]").map{|i| i.inner_text.strip.gsub(/\s+|\t|\r|\n/," ").match(price_regex).to_a[0] }.compact
      prices = prices.map{|i| i unless i.match(currencies_regex).nil? }.compact unless prices.nil?

      # This is to exclude the 'basket'
      header_tag = doc.at('body').xpath("//html/header").map{|i| i.inner_text.strip.gsub(/\t|\r|\n/," ").match(price_regex).to_a[0] }

      # Get the first price which is not in the header tag
      price = (prices - header_tag)[0]

    end

    # Replace symbols for the monetize gem to work properply
    # price.gsub('$','USD').gsub('€','EUR').gsub('£','GBP').to_s unless price.nil?
    currencies = {'$' => 'USD','€' => 'EUR','kr' => 'DKK','kr.' => 'DKK',',-' => 'DKK', '£' => 'GBP', 'Rs.' => 'INR'}
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

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}[0]['src']

    # page_info[:img] = doc.css('body img').select{|img| img[:width].to_i > 200}['src'].map(&:inspect).join(', ')

    # page_info[:img] = doc.css('body img')[0]['src']

    # if page_info[:img][0].starts_with?("/") # Checks if src is a relative reference
    #   page_info[:img] = URI::join(url, page_info[:img]).to_s # Sets the absoloute reference
    # end
end