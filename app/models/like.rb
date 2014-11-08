# == Schema Information
#
# Table name: likes
#
#  id         :integer          not null, primary key
#  item_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Like < ActiveRecord::Base
  attr_accessible :item_id, :user_id

  belongs_to :user
  belongs_to :item

  validates :user_id, presence: true
  validates :item_id, presence: true

  validates :user_id, :uniqueness => { :scope => :item_id }

end
