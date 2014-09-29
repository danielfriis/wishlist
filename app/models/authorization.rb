# == Schema Information
#
# Table name: authorizations
#
#  id               :integer          not null, primary key
#  provider         :string(255)
#  uid              :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  oauth_token      :string(255)
#  oauth_expires_at :datetime
#

class Authorization < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id, :user
  belongs_to :user
  # validates_presence_of :user_id, :uid, :provider
  # validates_uniqueness_of :uid, :scope => :provider

	def self.find_with_omniauth(auth)
	  find_by_provider_and_uid(auth['provider'], auth['uid'])
	end

	def self.create_with_omniauth(auth, user)
	  user ||= User.create_with_omniauth!(auth)
	  Authorization.create do |user_auth|
	  	user_auth.user_id = user.id
	  	user_auth.oauth_token = auth['credentials']['token']
	  	user_auth.oauth_expires_at = Time.at(auth['credentials']['expires_at'])
	  	user_auth.uid = auth['uid']
	  	user_auth.provider = auth['provider']
	  end
	end

	def renew_token(auth)
		self.oauth_token = auth['credentials']['token']
		self.oauth_expires_at = Time.at(auth['credentials']['expires_at'])
		self.save
	end
end
