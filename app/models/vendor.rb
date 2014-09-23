# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string(255)
#

class Vendor < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  attr_accessible :name, :url

  has_many :items, dependent: :destroy
  has_many :wishes, through: :items

  has_many :relationships, as: :followed
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

  def self.search(query)
    # where(:title, query) -> This would return an exact match of the query
    where("upper(vendors.name) like upper(?)", "%#{query}%") 
  end

  def base_uri
    vendor_path(self)
  end

  def self.most_followers
    joins("left join relationships on relationships.followed_id = vendors.id AND relationships.followed_type = 'Vendor'")
    .select('vendors.*, count(relationships.followed_id) as relationships_count')
    .group('vendors.id')
    .order('relationships_count desc, vendors.created_at desc')
  end

end
