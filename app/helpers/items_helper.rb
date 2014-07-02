module ItemsHelper

	def exchanged_price(item)
    if request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first == 'da'
      new_price = item.price.exchange_to("DKK")
      "#{new_price.currency.iso_code}" + " #{new_price.format(:symbol => false)}"
    else
      "#{item.price.currency.iso_code}" + " #{item.price.format(:symbol => false)}"
    end
  end

end