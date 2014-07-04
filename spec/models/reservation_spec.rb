# == Schema Information
#
# Table name: reservations
#
#  id         :integer          not null, primary key
#  wish_id    :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Reservation do
  pending "add some examples to (or delete) #{__FILE__}"
end
