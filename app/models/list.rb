class List < ActiveRecord::Base
  attr_accessible :name
  belongs_to :user
  
  validates :name, presence: true, length: { maximum: 60 }
  validates :user_id, presence: true
end
