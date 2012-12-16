require 'spec_helper'

describe "List pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "list creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a list" do
        expect { click_button "Create list" }.not_to change(List, :count)
      end

      describe "error messages" do
        before { click_button "Create list" }
        it { should have_content('error') } 
      end
    end

    describe "with valid information" do

      before { fill_in 'list_name', with: "Lorem ipsum" }
      it "should create a list" do
        expect { click_button "Create list" }.to change(List, :count).by(1)
      end
    end
  end
end