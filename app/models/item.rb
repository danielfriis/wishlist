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
#  gender     :string(255)
#  vendor_id  :integer
#  via        :string(255)
#

class Item < ActiveRecord::Base
  attr_accessible :link, :title, :image, :remote_image_url, :gender, :vendor_id, :via

  belongs_to :vendor

  has_many :wishes, dependent: :destroy
  has_many :lists, through: :wishes
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :wishes, :lists 

  mount_uploader :image, ImageUploader

  validates :title, presence: true, length: { maximum: 140 }
  validates :image,
    :file_mime_type => {
      :content_type => /image/
    }

  is_impressionable

  def self.sort(general, gender, current_user)
    if gender == "all"
      sort_general(general, current_user)
    else
      sort_general(general, current_user).where("gender = ?", gender)
    end
  end

  def self.sort_general(general, current_user)
    if general == "recent"
      order("created_at desc")
    elsif general == "following"
      followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
      followed_user_lists = "SELECT id FROM lists WHERE user_id IN (#{followed_user_ids})"
      followed_user_wishes = "SELECT item_id FROM wishes WHERE list_id IN (#{followed_user_lists})"
      where("id IN (#{followed_user_wishes})", user_id: current_user.id)
      .order("created_at desc")
    else
      start_date = (Time.now - 10.days)
      end_date = Time.now
      joins("left join impressions on impressions.impressionable_id = items.id and impressions.impressionable_type = 'Item'")
          .select("count(distinct(case when (impressions.created_at BETWEEN '#{start_date}' AND '#{end_date}') then ip_address end)) as counter, impressionable_id, items.gender, items.title, items.id, items.image")
          .group('items.id', 'impressions.impressionable_id')
          .order("counter desc")
    end
  end
end
