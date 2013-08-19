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
	include RankedModel

  attr_accessible :item_id, :list_id, :note, :row_order, :row_order_position
  belongs_to :list
  ranks :row_order,
  	:with_same => :list_id
  belongs_to :item
end
