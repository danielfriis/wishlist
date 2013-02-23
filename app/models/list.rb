# == Schema Information
#
# Table name: lists
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class List < ActiveRecord::Base
  attr_accessible :name

  belongs_to :user
  has_many :wishes
  has_many :items, through: :wishes

  accepts_nested_attributes_for :wishes, :items
  
  validates :name, presence: true, length: { maximum: 60 }
  validates :user_id, presence: true
end
