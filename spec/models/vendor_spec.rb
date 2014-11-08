# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  slug       :string(255)
#  bio        :text
#  twitter    :string(255)
#  instagram  :string(255)
#  pinterest  :string(255)
#  facebook   :string(255)
#  avatar     :string(255)
#

require 'spec_helper'

describe Vendor do
  pending "add some examples to (or delete) #{__FILE__}"
end
