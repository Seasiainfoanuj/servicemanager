FactoryGirl.define do
  factory :hire_agreement_type do
    name Faker::Lorem.word
    damage_recovery_fee Faker::Number.number(2)
    fuel_service_fee Faker::Number.number(2)
  end
end
