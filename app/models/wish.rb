# == Schema Information
#
# Table name: wishes
#
#  id         :integer          not null, primary key
#  list_id    :integer
#  item_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Wish < ActiveRecord::Base
  attr_accessible :item_id, :list_id
  belongs_to :list
  belongs_to :item
end
