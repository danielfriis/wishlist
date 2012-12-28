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
    title "Shirt"
    link "www.example.com"
    list
  end

end
