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

require 'spec_helper'

describe Admission do
  pending "add some examples to (or delete) #{__FILE__}"
end
