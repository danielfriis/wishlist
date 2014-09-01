require 'uri'
require 'json'

module PluginHelper

  def domain_of_url(url)
    encoded_url = URI.encode(url.to_s)
    URI.parse(encoded_url).host
  end

  def remove_wishes_cookie
    cookies.delete :wishes, path: '/'
  end

  def get_wishes
    JSON.parse(cookies[:wishes] || '{}')
  end

  def save_wishes_to_list(list)
    wishes = get_wishes.map do |w|
      w.symbolize_keys!

      item = Item.find_or_create_by_link!(w[:link]) do |c|
        c.assign_attributes(w)
        c.price = Money.parse(w[:price]) unless w[:price].blank?
        c.vendor_id = Vendor.custom_find_or_create(w[:link])
      end

      Wish.create! title: item.title, list_id: list.id, item_id: item.id
    end

    list.wishes << wishes
    remove_wishes_cookie

    wishes
  end

end
