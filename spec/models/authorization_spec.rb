# == Schema Information
#
# Table name: authorizations
#
#  id               :integer          not null, primary key
#  provider         :string(255)
#  uid              :string(255)
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  oauth_token      :string(255)
#  oauth_expires_at :datetime
#

require 'spec_helper'

describe Authorization do
  pending "add some examples to (or delete) #{__FILE__}"
end
