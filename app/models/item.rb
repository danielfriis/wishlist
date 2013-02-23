# == Schema Information
#
# Table name: items
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  link       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  image      :string(255)
#

class Item < ActiveRecord::Base
  attr_accessible :link, :title, :image, :remote_image_url

  has_many :wishes
  has_many :lists, through: :wishes

  accepts_nested_attributes_for :wishes, :lists 

  mount_uploader :image, ImageUploader

  validates :title, presence: true, length: { maximum: 140 }
  validates_presence_of :image
end
