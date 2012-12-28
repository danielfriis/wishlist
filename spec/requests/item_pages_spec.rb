require 'spec_helper'

describe "Item pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, user: user)}
  before { sign_in user }

  describe "item creation" do
    before do 
      visit user_list_path(user, list)
      click_link "Add wish"
    end

    describe "with invalid information" do

      it "should not create an item" do
        expect { click_button "Add" }.not_to change(Item, :count)
        current_path.should eq(new_item_url)
      end

      # describe "error messages" do
      #   before { click_button "Add" }
      #   it { should have_content('error') } 
      # end
    end

    describe "with valid information" do

      before { fill_in 'item_title', with: "Lorem ipsum" }
      it "should create a item" do
        expect { click_button "Add" }.to change(Item, :count).by(1)
      end
    end
  end
end