# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Vendor < ActiveRecord::Base
  attr_accessible :name, :url

  has_many :items

  def self.custom_find_or_create(link)
  	name = ApplicationController.helpers.get_host_without_www(link)
  	vendor = Vendor.create_with(url: ApplicationController.helpers.get_host_with_www(link)).find_or_create_by_name(name)
  	return vendor.id
  end
end
