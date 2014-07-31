task :subscribe_mailchimp => :environment do
 User.find_each do |user|
 	user.subscribe_email
 end
end

task :send_survey => :environment do
 User.find_each do |user|
 	UserMailer.delay.survey(user.id)
 end
end

task :send_friendly_reminder => :environment do
	nosend = []
	nosend << "louisefriis@gmail.com"
	nosend << "ole@ole.kristensen.name"
	nosend << "tsk@netcompany.com"
	nosend << "jannick4@hotmail.com"
	nosend << "emmaarfelt@gmail.com"
	nosend << "annifong9@gmail.com"
	nosend << "tinat86@hotmail.com"
	nosend << "niels.wilken@gmail.com"
	nosend << "andrea.baccenetti@gmail.com"
	nosend << "henrikbn@hotmail.com"
	nosend << "langomango@gmail.com"
	nosend << "kqualmann@gmail.com"
	nosend << "lullumut@gmail.com"
	nosend << "jhfriisj@gmail.com"
	nosend << "cgallstar@gmail.com"
	nosend << "aliaproductions@live.dk"
	nosend << "thelle.k@gmail.com"
	nosend << "casperneergaard@hotmail.com"
	User.find_each do |user|
	 	unless nosend.include? user.email
	 		UserMailer.delay.friendly_reminder(user.id)
	 	end
	end
end

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

task :set_relationships => :environment do
	Relationship.find_each do |rel|
		rel.followed_type = "User"
		rel.save
	end
end

task :generate_vendor_slug => :environment do
 Vendor.find_each do |vendor|
 	vendor.slug = vendor.create_unique_slug
 	vendor.save
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
	total = Item.all.count
	progressbar = ProgressBar.create(format: '%a %E %c/%C |%B| %p%% %t',total: total)
	Item.find_each do |item|
		# if item.price.nil?
			price = LinkPreviewParser.price(item.link).to_money rescue nil
			if price.blank?
				item.price = ""
			else
				item.price = price.to_money
			end
			item.save
			progressbar.increment
		# end
	end
end

task :no_item_price => :environment do
	total = Item.all.count
	progressbar = ProgressBar.create(format: '%a %E %c/%C |%B| %p%% %t',total: total)
	Item.find_each do |item|
		if item.price.nil?
			price = LinkPreviewParser.price(item.link).to_money rescue nil
			item.price = price.to_money unless price.nil?
			item.save
			progressbar.increment
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