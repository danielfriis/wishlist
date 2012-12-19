require 'spec_helper'

describe Item do

	let(:list) { FactoryGirl.create(:list) }
  before do
    # This code is wrong!
    @item = Item.new(title: "Lorem ipsum", list_id: list.id)
  end

  subject { @item }

  it { should respond_to(:title) }
  it { should respond_to(:list_id) }

  it { should be_valid }

  describe "when list_id not present" do
  	before { @item.list_id = nil }
  	it { should_not be_valid }
  end
end