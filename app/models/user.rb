# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string(255)
#  remember_token  :string(255)
#  age             :integer
#  location        :string(255)
#  avatar          :string(255)
#  gender          :string(255)
#

class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader

  attr_accessible :name, :email, :avatar, :password, :password_confirmation
  has_secure_password
  has_many :lists, dependent: :destroy
  has_many :wishes, through: :lists
  has_many :items, through: :wishes
  has_many :authorizations

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  before_update :check_password

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence:   true,
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :password_confirmation, presence: true, on: :create
  validates :slug, uniqueness: true, presence: true, 
                    exclusion: { in: %w[signup signin signout help about contact terms privacy linkpreview bookmarklet]}

  before_validation :generate_slug

  def self.create_with_omniauth!(auth)
    create! do |user|
      user.name = auth['info']['name']
      user.email = auth['info']['email']
      user.remote_avatar_url = auth['info']['image'].split("=")[0] << "=large"
      user.gender = auth['extra']['raw_info']['gender'].titleize
      user.location = auth['info']['location']
      user.password = "foobar"
      user.password_confirmation = "foobar"
    end
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


  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def check_password
      is_ok = self.password.nil? || self.password.empty? || self.password.length >= 6

      self.errors[:password] << "Password is too short (minimum is 6 characters)" unless is_ok

      is_ok # The callback returns a Boolean value indicating success; if it fails, the save is blocked
    end
end
