require 'uri'

module PluginHelper

  def domain_of_url(url)
    encoded_url = URI.encode(url.to_s)
    URI.parse(encoded_url).host
  end

  def save_wishes_from_cookie
    ActiveSupport::JSON.decode(cookies[:wishes]).map do |w|
      item = Item.create!(
                          title: w['title'],
                          image: w['picture'],
                          link:  w['link'],
                          price: w['price'].to_i
                          )

      Wish.create! title: item.title, item_id: item.id
    end
  end

end
