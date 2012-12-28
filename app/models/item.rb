# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  link       :string(255)
#  list_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Item < ActiveRecord::Base
  attr_accessible :link, :list_id, :title
  belongs_to :list

  validates :title, presence: true, length: { maximum: 140 }
  validates :list_id, presence: true
end
