class Vendor < ActiveRecord::Base
  attr_accessible :name, :url

  has_many :items

  def self.custom_find_or_create(link)
  	name = ApplicationController.helpers.get_host_without_www(link)
  	vendor = Vendor.create_with(url: ApplicationController.helpers.get_host_with_www(link)).find_or_create_by_name(name)
  	return vendor.id
  end
end
