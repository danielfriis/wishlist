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

require 'spec_helper'

describe Relationship do
  pending "add some examples to (or delete) #{__FILE__}"
end
