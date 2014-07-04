# == Schema Information
#
# Table name: items
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  link           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  image          :string(255)
#  gender         :string(255)
#  vendor_id      :integer
#  via            :string(255)
#  price_cents    :integer
#  price_currency :string(255)
#

class Item < ActiveRecord::Base
  attr_accessible :link, :title, :image, :remote_image_url, :gender, :vendor_id, :via, :price

  belongs_to :vendor

  has_many :wishes, dependent: :destroy
  has_many :lists, through: :wishes
  has_many :comments, as: :commentable

  accepts_nested_attributes_for :wishes, :lists

  monetize :price_cents, with_model_currency: :price_currency, :allow_nil => true

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
      not_hidden = "SELECT item_id FROM wishes WHERE hide = :false"
      with_pictures
        .where("id IN (#{not_hidden})", false: false)
        .order("created_at desc")
    elsif general == "following"
      followed_user_ids = "SELECT followed_id FROM relationships WHERE (follower_id = :user_id AND followed_type = 'User')"
      followed_user_lists = "SELECT id FROM lists WHERE user_id IN (#{followed_user_ids})"
      followed_user_wishes = "SELECT item_id FROM wishes WHERE list_id IN (#{followed_user_lists}) AND hide = :false"
      followed_vendors_ids = "SELECT followed_id FROM relationships WHERE (follower_id = :user_id AND followed_type = 'Vendor')"
      followed_vendors_items = "SELECT id FROM items WHERE vendor_id IN (#{followed_vendors_ids})"
      followed_vendors_wishes = "SELECT item_id FROM wishes WHERE item_id IN (#{followed_vendors_items})"
      with_pictures
        .where("(id IN (#{followed_user_wishes})) OR (id IN (#{followed_vendors_wishes}))", user_id: current_user.id, false: false)
        .order("created_at desc")
    else
      start_date = (Time.now - 5.days)
      end_date = Time.now
      not_hidden = "SELECT item_id FROM wishes WHERE hide = :false"
      with_pictures
          .joins("left join wishes on item_id = items.id")
          .joins("left join impressions on impressions.impressionable_id = items.id and impressions.impressionable_type = 'Item'")
          .select("items.*, ((count(distinct(case when impressions.created_at BETWEEN '#{start_date}' AND '#{end_date}' then ip_address end)) * 20) + (count(wishes.id) / 500)) as counter, impressionable_id")
          .group('items.id', 'impressions.impressionable_id')
          .where("items.id IN (#{not_hidden})", false: false)
          .order("counter desc, items.created_at desc")
    end
  end

  def self.with_pictures
    self.where(Item.arel_table[:via].not_eq("no_link").and(Item.arel_table[:via].not_eq("no_image")))
  end
end
