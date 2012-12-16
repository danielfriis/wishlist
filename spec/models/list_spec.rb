require 'spec_helper'

describe List do

  let(:user) { FactoryGirl.create(:user) }
  before { @list = user.lists.build(name: "Lorem ipsum") }

  subject { @list }

  it { should respond_to(:name) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
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
end
