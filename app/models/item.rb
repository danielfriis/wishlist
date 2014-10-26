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
#  via            :string(255)      default("default")
#  price_cents    :integer
#  price_currency :string(255)
#

class Item < ActiveRecord::Base
  include Rails.application.routes.url_helpers
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

  def update_price
    self.price = LinkPreviewParser.price(self.link).to_money
    self.save
  end

  handle_asynchronously :update_price, :priority => 10

  def self.search(query)
    # where(:title, query) -> This would return an exact match of the query
    where("upper(items.title) like upper(?)", "%#{query}%")
  end

  def base_uri
    item_path(self)
  end

  def self.sort(general, gender, current_user)
    if gender == "all"
      sort_general(general, current_user)
    else
      sort_general(general, current_user).where("gender = ?", gender)
    end
  end

  def self.sort_general(general, current_user)
    if general == "recent"
      recent
    elsif general == "following"
      following(current_user)
    elsif general == "christmas"
      occation(['christmas', 'jul'])
    elsif general == "birthday"
      occation([URI.decode('f%C3%B8dselsdag'), 'birthday'])
    else
      popular
    end
  end

  def self.occation(query)
    if query.kind_of?(Array)
      query = query.join("%') OR upper(lists.name) like upper('%")
    else
      query
    end
    lists = "SELECT lists.id from lists WHERE upper(lists.name) like upper('%#{query}%')"
    wishes = "SELECT item_id from wishes WHERE list_id IN (#{lists})"
    where("items.id IN (#{wishes})")
      .popular
  end

  def self.recent
    with_pictures
        .no_hidden_wishes
        .order("created_at desc")
  end

  def self.following(current_user)
    followed_user_ids = "SELECT followed_id FROM relationships WHERE (follower_id = :user_id AND followed_type = 'User')"
      followed_user_lists = "SELECT id FROM lists WHERE user_id IN (#{followed_user_ids})"
      followed_user_wishes = "SELECT item_id FROM wishes WHERE list_id IN (#{followed_user_lists}) AND hide = :false"
      followed_vendors_ids = "SELECT followed_id FROM relationships WHERE (follower_id = :user_id AND followed_type = 'Vendor')"
      followed_vendors_items = "SELECT id FROM items WHERE vendor_id IN (#{followed_vendors_ids})"
      followed_vendors_wishes = "SELECT item_id FROM wishes WHERE item_id IN (#{followed_vendors_items})"
      with_pictures
        .where("(id IN (#{followed_user_wishes})) OR (id IN (#{followed_vendors_wishes}))", user_id: current_user.id, false: false)
        .no_hidden_wishes
        .order("created_at desc")
  end

  def self.popular
    start_date = (Time.now - 5.days)
    start_date_w = (Time.now - 21.days)
    end_date = Time.now
    with_pictures
        .joins("left join wishes on item_id = items.id")
        .joins("left join impressions on impressions.impressionable_id = items.id and impressions.impressionable_type = 'Item'")
        .select("items.*, (count(distinct(case when impressions.created_at BETWEEN '#{start_date}' AND '#{end_date}' then ip_address end)) + (count(distinct(case when wishes.created_at BETWEEN '#{start_date_w}' AND '#{end_date}' then wishes.id end)) * 5)) as counter, impressionable_id")
        .group('items.id', 'impressions.impressionable_id')
        .no_hidden_wishes
        .order("counter desc, items.created_at desc")
  end

  def self.no_hidden_wishes
    not_private_list = "SELECT id FROM lists WHERE private = :false"
    not_hidden = "SELECT item_id FROM wishes WHERE (hide = :false AND list_id IN (#{not_private_list}))"
    where("items.id IN (#{not_hidden})", false: false)
  end

  def self.with_pictures
    where(Item.arel_table[:via].not_eq("no_link").and(Item.arel_table[:via].not_eq("no_image")))
  end

  def popularity_score
    start_date = (Time.now - 5.days)
    start_date_w = (Time.now - 21.days)
    end_date = Time.now
    view_count = impressions.select('distinct(ip_address)').where("created_at BETWEEN '#{start_date}' AND '#{end_date}'").count
    wish_count = wishes.where("created_at BETWEEN '#{start_date_w}' AND '#{end_date}'").count
    pop_score = view_count + wish_count * 5
  end
end
