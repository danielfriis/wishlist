# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  password_digest        :string(255)
#  remember_token         :string(255)
#  age                    :integer
#  location               :string(255)
#  avatar                 :string(255)
#  gender                 :string(255)
#  slug                   :string(255)
#  admin                  :boolean          default(FALSE)
#  follower_notification  :boolean          default(TRUE)
#  comment_notification   :boolean          default(TRUE)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  twitter                :string(255)
#  instagram              :string(255)
#  website                :string(255)
#  bio                    :text
#  pinterest              :string(255)
#  facebook               :string(255)
#  fb_friends             :text
#  birthdate              :date
#

require 'spec_helper'

describe User do

  before do
    @user = FactoryGirl.create(:user)
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:gender) }
  it { should respond_to(:birthdate) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:lists) }
  it { should respond_to(:items) }

  it { should be_valid }

  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end

  describe "when email address is already taken" do
    it "should no be valid" do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
      user_with_same_email.should_not be_valid
    end
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end
  
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe "list associations" do

    before { @user.save }
    let!(:older_list) do 
      FactoryGirl.create(:list, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_list) do
      FactoryGirl.create(:list, user: @user, created_at: 1.hour.ago)
    end

    it "should destroy associated lists" do
      lists = @user.lists.dup
      @user.destroy
      lists.should_not be_empty
      lists.each do |list|
        List.find_by_id(list.id).should be_nil
      end
    end
  end
end
