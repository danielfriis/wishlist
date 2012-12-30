include ActionDispatch::TestProcess
FactoryGirl.define do

  sequence(:email) { |n| "User#{n}@example.com"}

  factory :user do
    name     "Michael Hartl"
    email
    password "foobar"
    password_confirmation "foobar"
  end

  factory :list do
    name "Lorem ipsum"
    user
  end

  factory :item do
    image { fixture_file_upload(Rails.root.join('spec', 'support', 'test_images' , 'google.png'), 'image/png') }
    title "Shirt"
    link "www.example.com"
    list
  end

end
