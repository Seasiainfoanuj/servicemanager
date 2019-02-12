FactoryGirl.define do
  factory :newsletter_subscription do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    sequence(:email) {|n| "person#{n}@example.com" }
    subscription_origin 'cms'
  end
end