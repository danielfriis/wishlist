# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text
#  commentable_id   :integer
#  commentable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#

class Comment < ActiveRecord::Base
  attr_accessible :content, :user_id
  belongs_to :user
  belongs_to :commentable, polymorphic: true
end
