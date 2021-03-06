# == Schema Information
#
# Table name: relationships
#
#  id            :integer          not null, primary key
#  follower_id   :integer
#  followed_id   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  followed_type :string(255)
#

class Relationship < ActiveRecord::Base
  attr_accessible :followed_id, :follower_id, :followed_type

  belongs_to :follower, class_name: "User"
  belongs_to :followed, polymorphic: true

  validates :follower_id, presence: true
  validates :followed_id, presence: true

end
