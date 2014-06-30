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

  has_many :items, dependent: :destroy
  has_many :wishes, through: :items

  has_many :relationships, foreign_key: "followed_id"
  has_many :followers, through: :relationships, source: :follower

  validates :slug, uniqueness: true, presence: true
  validates :name, presence: true

	before_validation :create_unique_slug

	def to_param
		slug
	end

	def create_unique_slug
		if self.new_record? || self.slug.blank?
      if Vendor.where(:slug => name.parameterize).count > 0
        n = 1
        while Vendor.where(:slug => "#{self.name.parameterize}-#{n}").count > 0
          n += 1
        end
        self.slug = "#{self.name.parameterize}-#{n}"
      else
        self.slug = self.name.parameterize
      end
    end
	end

  def self.custom_find_or_create(link)
  	name = ApplicationController.helpers.get_host_without_www(link)
  	vendor = Vendor.create_with(url: ApplicationController.helpers.get_host_with_www(link)).find_or_create_by_name(name)
  	return vendor.id
  end

end
