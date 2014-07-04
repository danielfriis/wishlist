class Reservation < ActiveRecord::Base
  attr_accessible :user_id, :wish_id
  belongs_to :user
  belongs_to :wish

  validates :user_id, presence: true
  validates :wish_id, presence: true

end
