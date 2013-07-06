# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  link       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image      :string(255)
#

class Item < ActiveRecord::Base
  attr_accessible :link, :title, :image, :remote_image_url

  has_many :wishes
  has_many :lists, through: :wishes

  accepts_nested_attributes_for :wishes, :lists 

  mount_uploader :image, ImageUploader

  validates :title, presence: true, length: { maximum: 140 }
  validates_presence_of :image

  is_impressionable

  def self.sort(general, gender)
    if gender == "all"
      sort_general(general)
    else
      sort_general(general).where("items.gender = ?", gender)
    end
  end

  def self.sort_general(general)
    if general == "recent"
      order("created_at desc")
    else
      start_date = (Time.now - 10.days)
      end_date = Time.now
      joins("left join impressions on impressions.impressionable_id = items.id and impressions.impressionable_type = 'Item'")
          .select("count(distinct(case when (impressions.created_at BETWEEN '#{start_date}' AND '#{end_date}') then ip_address end)) as counter, impressionable_id, items.gender, items.title, items.id, items.image")
          .group('items.id', 'impressions.impressionable_id')
          .order("counter desc")
    end
  end

  # def self.popular
  # 	start_date = (Time.now - 10.days)
  #   end_date = Time.now
  # 	joins("left join impressions on impressions.impressionable_id = items.id and impressions.impressionable_type = 'Item'")
  #       .select("count(distinct(case when (impressions.created_at BETWEEN '#{start_date}' AND '#{end_date}') then ip_address end)) as counter, impressionable_id, items.title, items.id, items.image")
  #       .group('items.id', 'impressions.impressionable_id')
  #       .order("counter desc")
  # end

  # def self.recent
  # 	order("created_at desc")
  # end
end
