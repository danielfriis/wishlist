# == Schema Information
#
# Table name: admissions
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  accessible_id   :integer
#  accessible_type :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Admission < ActiveRecord::Base
  belongs_to :user
  belongs_to :accessible, polymorphic: true
  attr_accessible :accessible_id, :accessible_type, :user_id

  validates_uniqueness_of :user_id, scope: [:accessible_id, :accessible_type]

end
