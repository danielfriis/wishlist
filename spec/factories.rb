include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}
    birthdate ("01/jan/1980".to_date)
    gender "Male"
    password "foobar"
    password_confirmation "foobar"
  end

  factory :list do
    name "My sample list"
    user
  end

  factory :item do
    image { fixture_file_upload(Rails.root.join('spec', 'support', 'test_images', 'google.png'), 'image/png') }
    title "My sample item"
    link "www.example.com"
    list
  end
end