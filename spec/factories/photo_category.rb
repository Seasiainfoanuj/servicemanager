FactoryGirl.define do
  factory :photo_category do
    sequence(:name) {|n| "#{Faker::Lorem.word}-#{n*100}" }
  end
end