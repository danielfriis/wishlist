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
#  image      :string(255)
#

class Item < ActiveRecord::Base
  attr_accessible :link, :list_id, :title, :image, :remote_image_url
  belongs_to :list
  mount_uploader :image, ImageUploader

  validates :title, presence: true, length: { maximum: 140 }
  validates :list_id, presence: true
  validates_presence_of :image
end
