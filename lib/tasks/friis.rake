task :generate_slug => :environment do
 User.find_each do |user|
 	user.slug = user.generate_slug
 	user.save
 end
end	

task :create_vendors => :environment do
	Item.find_each do |item|
		name = ApplicationController.helpers.get_host_without_www(item.link)
		item.vendor_id = Vendor.find_or_create_by_name(name).id
		item.vendor.url = ApplicationController.helpers.get_host_with_www(item.link)
		item.save
		item.vendor.save
	end
end