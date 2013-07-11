# == Schema Information
#
# Table name: wishes
#
#  id         :integer          not null, primary key
#  list_id    :integer
#  item_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  note       :string(255)
#

class Wish < ActiveRecord::Base
  attr_accessible :item_id, :list_id, :note
  belongs_to :list, touch: true
  belongs_to :item
end
