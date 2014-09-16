# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_digest        :string(255)
#  remember_token         :string(255)
#  age                    :integer
#  location               :string(255)
#  avatar                 :string(255)
#  gender                 :string(255)
#  slug                   :string(255)
#  admin                  :boolean          default(FALSE)
#  follower_notification  :boolean          default(TRUE)
#  comment_notification   :boolean          default(TRUE)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  twitter                :string(255)
#  instagram              :string(255)
#  website                :string(255)
#  bio                    :text
#  pinterest              :string(255)
#

class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  attr_accessible :name, :email, :avatar, :remove_avatar, :password, :password_confirmation, :gender, :follower_notification, :comment_notification, :twitter, :instagram, :pinterest, :bio, :location, :website, :facebook
  has_secure_password
  has_many :lists, dependent: :destroy
  has_many :wishes, through: :lists
  has_many :items, through: :wishes
  has_many :authorizations, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :reservations, dependent: :destroy

  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed, source_type: 'User'
  has_many :followed_vendors, through: :relationships, source: :followed, source_type: 'Vendor'

  has_many :reverse_relationships, as: :followed,
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  before_update :check_password

  validates :bio, length: { maximum: 160 }
  validates :twitter, length: { maximum: 15 }
  validates :instagram, length: { maximum: 30 }
  validates :pinterest, length: { maximum: 15 }

  before_save :clean_socials

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :slug, uniqueness: true, presence: true, 
                    exclusion: { in: %w[admin signup signin signout help about contact terms privacy linkpreview bookmarklet inspiration vendors]}

  before_validation :generate_slug

  def self.create_with_omniauth!(auth)
    generated_password = SecureRandom.hex[0,8]
    user = create! do |user|
      user.name = auth['info']['name']
      user.email = auth['info']['email']
      user.remote_avatar_url = auth['info']['image'].split("=")[0] << "=large"
      user.gender = auth['extra']['raw_info']['gender'].titleize
      user.location = auth['info']['location']
      user.password = generated_password
      user.password_confirmation = generated_password
    end
    UserMailer.delay.signup_confirmation(user.id, generated_password)
    user.delay.subscribe_email
    return user
  end

  def subscribe_email
    gb = Gibbon::API.new
    first_name = name.split(" ").first
    last_name = name.split(" ").last unless name.split(" ").first == name.split(" ").last
    gb.lists.subscribe({:id => ENV["MAILCHIMP_LIST_ID"], :email => {:email => email}, :merge_vars => {:FNAME => first_name, :LNAME => last_name}, :double_optin => false})
  end

  def to_param
    slug
  end

  def generate_slug
    if self.new_record? || self.slug.blank?
      if User.where(:slug => name.parameterize).count > 0
        n = 1
        while User.where(:slug => "#{self.name.parameterize}-#{n}").count > 0
          n += 1
        end
        self.slug = "#{self.name.parameterize}-#{n}"
      else
        self.slug = self.name.parameterize
      end
    end
  end

  def following?(other_user)
    relationships.find_by_followed_id_and_followed_type(other_user.id, other_user.class.name)
  end

  # def follow!(other_user)
  #   relationships.create!(followed_id: other_user.id)
  # end

  # def unfollow!(other_user)
  #   relationships.find_by_followed_id(other_user.id).destroy
  # end

  def self.search(query)
    # where(:title, query) -> This would return an exact match of the query
    where("upper(users.name) like upper(?)", "%#{query}%") 
  end

  def self.most_followers
    joins("left join relationships on relationships.followed_id = users.id AND relationships.followed_type = 'User'")
    .select('users.*, count(relationships.followed_id) as relationships_count')
    .group('users.id')
    .order('relationships_count desc, users.created_at desc')
  end

  def send_password_reset
    self.password_reset_token = SecureRandom.urlsafe_base64
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.delay.password_reset(self)
  end


  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def check_password
      is_ok = self.password.nil? || self.password.empty? || self.password.length >= 6

      self.errors[:password] << "Password is too short (minimum is 6 characters)" unless is_ok

      is_ok # The callback returns a Boolean value indicating success; if it fails, the save is blocked
    end

    def clean_socials
      self.twitter = self.twitter.gsub(/[^0-9A-Za-z_]/, '') unless self.twitter.blank?
      self.instagram = self.instagram.gsub(/[^0-9A-Za-z_]/, '') unless self.instagram.blank?
      self.pinterest = self.pinterest.gsub(/[^0-9A-Za-z_]/, '') unless self.pinterest.blank?
      self.facebook = self.facebook.gsub(/[^0-9A-Za-z.]/, '') unless self.facebook.blank?
    end
end
