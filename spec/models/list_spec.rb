# == Schema Information
#
# Table name: lists
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe List do

  let(:user) { FactoryGirl.create(:user) }
  before { @list = user.lists.build(name: "Lorem ipsum") }

  subject { @list }

  it { should respond_to(:name) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:items) }
  its(:user) { should == user }

  it { should be_valid }
	describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        List.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "when user_id is not present" do
    before { @list.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @list.name = " " }
    it { should_not be_valid }
  end

  describe "with name that is too long" do
    before { @list.name = "a" * 61 }
    it { should_not be_valid }
  end

  describe "item associations" do

    before { @list.save }
    let!(:older_item) do 
      FactoryGirl.create(:item, list: @list, created_at: 1.day.ago)
    end
    let!(:newer_item) do
      FactoryGirl.create(:item, list: @list, created_at: 1.hour.ago)
    end

    it "should destroy associated items" do
      items = @list.items.dup
      @list.destroy
      items.should_not be_empty
      items.each do |item|
        Item.find_by_id(item.id).should be_nil
      end
    end
  end
end
