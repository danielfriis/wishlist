task :generate_slug => :environment do
 User.find_each do |user|
 	user.slug = user.generate_slug
 	user.save
 end
end	

task :create_vendors => :environment do
	Item.find_each do |item|
		name = ApplicationController.helpers.get_host_without_www(item.link.html_safe)
		item.vendor_id = Vendor.find_or_create_by_name(name).id
		item.vendor.url = ApplicationController.helpers.get_host_with_www(item.link.html_safe)
		item.save
		item.vendor.save
	end
end

task :item_via_default => :environment do
	Item.find_each do |item|
		if item.via.nil?
			item.via = "default"
			item.save
		end
	end
end

task :item_price_recent => :environment do
	Item.find_each(start: 1800, batch_size: 2000) do |item|
		# if item.price.nil?
			price = LinkPreviewParser.price(item.link).to_money rescue nil
			item.price = price.to_money unless price.nil?
			item.save
		# end
	end
end

task :item_price => :environment do
	Item.find_each do |item|
		# if item.price.nil?
			price = LinkPreviewParser.price(item.link).to_money rescue nil
			item.price = price.to_money unless price.nil?
			item.save
		# end
	end
end

task :no_item_price => :environment do
	Item.find_each do |item|
		if item.price.nil?
			price = LinkPreviewParser.price(item.link).to_money rescue nil
			item.price = price.to_money unless price.nil?
			item.save
		end
	end
end

task :gender_default => :environment do
	User.find_each do |user|
		if user.gender.nil?
			user.gender = "Male"
			user.save
		end
	end
end

task :hide_wish => :environment do
	Wish.find_each do |wish|
		if wish.hide.nil?
			wish.hide = false
			wish.save
		end
	end
end

task :title_wish => :environment do
	Wish.find_each do |wish|
		if wish.title.nil?
			wish.title = wish.item.title
			wish.save
		end
	end
end