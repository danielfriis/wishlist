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
end