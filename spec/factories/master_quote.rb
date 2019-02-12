FactoryGirl.define do
  factory :master_quote do
    association :type, factory: [:master_quote_type]
    vehicle_make Faker::Lorem.word
    vehicle_model Faker::Lorem.word
    transmission_type Faker::Lorem.word
    name Faker::Lorem.word
    seating_number Faker::Number.number(2)
    terms Faker::Lorem.paragraphs
    notes Faker::Lorem.paragraphs
  end
end
