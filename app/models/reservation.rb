# == Schema Information
#
# Table name: reservations
#
#  id         :integer          not null, primary key
#  wish_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Reservation < ActiveRecord::Base
  attr_accessible :user_id, :wish_id
  belongs_to :user
  belongs_to :wish

  validates :user_id, presence: true
  validates :wish_id, presence: true

end
