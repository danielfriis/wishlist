# == Schema Information
#
# Table name: authorizations
#
#  id         :integer          not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
	  Authorization.create(:user_id => user.id, :uid => auth['uid'], :provider => auth['provider'])
	end
end
