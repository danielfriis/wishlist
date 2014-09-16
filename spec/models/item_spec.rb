# == Schema Information
#
# Table name: items
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  link           :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  image          :string(255)
#  gender         :string(255)
#  vendor_id      :integer
#  via            :string(255)      default("default")
#  price_cents    :integer
#  price_currency :string(255)
#

require 'spec_helper'

describe Item do

  let(:user) { FactoryGirl.create(:user) }
	let(:list) { FactoryGirl.create(:list) }

  before do
    @item = list.items.build(title: "Lorem ipsum")
    @item.image = fixture_file_upload('/test_images/google.png', 'image/png')
  end

  subject { @item }

  it { should respond_to(:title) }
  it { should respond_to(:list_id) }
  it { should respond_to(:list) }
  it { should respond_to(:image) }
  it { should respond_to(:remote_image_url) }
  its(:list) { should == list }

  it { should be_valid }

  describe "when list_id not present" do
  	before { @item.list_id = nil }
  	it { should_not be_valid }
  end

  describe "when image not present" do
    before { @item.image = " " }
    it { should_not be_valid }
  end

  describe "with blank title" do
    before { @item.title = " " }
    it { should_not be_valid }
  end

  describe "with title that is too long" do
    before { @item.title = "a" * 141 }
    it { should_not be_valid }
  end
end
