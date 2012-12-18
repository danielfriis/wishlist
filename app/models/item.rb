class Item < ActiveRecord::Base
  attr_accessible :link, :list_id, :title
  validates :list_id, presence: true
end
