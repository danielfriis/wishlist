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
#  row_order  :integer
#

require 'spec_helper'

describe Wish do
  pending "add some examples to (or delete) #{__FILE__}"
end
