class Like < ActiveRecord::Base
  attr_accessible :item_id, :user_id

  belongs_to :user
  belongs_to :item

  validates :user_id, presence: true
  validates :item_id, presence: true

  validates :user_id, :uniqueness => { :scope => :item_id }

end
