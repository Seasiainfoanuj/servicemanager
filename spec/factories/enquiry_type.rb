# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :enquiry_type do
    name Faker::Lorem.word
    sequence(:slug) {|n| "ENQTYP-#{n}"}
  end
end
