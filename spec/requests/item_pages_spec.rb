require 'spec_helper'

describe "Item pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, user: user)}
  before { sign_in user }

  describe "item creation" do
    before do 
      visit new_item_path(user)
    end

    describe "with invalid information" do

      it "should not create an item" do
        expect { click_button "Add" }.not_to change(Item, :count)
        current_path.should == "/items"
      end

      # describe "error messages" do
      #   before { click_button "Add" }
      #   it { should have_content('error') } 
      # end
    end

    describe "with valid information" do

      before do
        attach_file 'item_image', Rails.root.join('spec', 'support', 'test_images', 'google.png')
        fill_in "item_title", with: "Lorem ipsum"
      end

      it "should create a item" do
        # expect { click_button "Add" }.to change(Item, :count).by(1)
        click_button "Add"
        current_path.should == "/items/1"
        page.should have_content("Item created")
      end
    end
  end

  describe "item destruction" do
    before { FactoryGirl.create(:item, list: list) }

    describe "as correct user" do
      before { visit user_list_path(user, list) }

      it "should delete a item" do
        expect { click_link "delete" }.to change(Item, :count).by(-1)
      end
    end
  end
end