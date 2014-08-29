require 'uri'

module PluginHelper

  def domain_of_url(url)
    encoded_url = URI.encode(url.to_s)
    URI.parse(encoded_url).host
  end

  def remove_wishes_cookie
    cookies.delete :wishes, path: '/'
  end

  def get_wishes
    ActiveSupport::JSON.decode(cookies[:wishes]) || []
  end

  def save_wishes_to_list(list)
    wishes = get_wishes.map do |w|
      item = Item.create!(
                          title: w['title'],
                          image: w['picture'],
                          link:  w['link'],
                          price: w['price'].to_i
                          )

      Wish.create! title: item.title, item_id: item.id
    end

    list.wishes << wishes
    remove_wishes_cookie

    wishes
  end

end
