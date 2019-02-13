FactoryGirl.define do
  factory :hire_vehicle do
    association :vehicle
    daily_km_allowance Faker::Number.number(3)
    daily_rate Faker::Number.number(3)
    excess_km_rate Faker::Number.number(3)
    active true
  end
end