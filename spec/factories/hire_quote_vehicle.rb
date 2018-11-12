FactoryGirl.define do
  factory :hire_quote_vehicle do
    association :hire_quote
    association :vehicle_model
    start_date Date.today + 10.days
    end_date Date.today + 50.days
    ongoing_contract false
    delivery_required true
    demobilisation_required false
    pickup_location Faker::Lorem.words
    dropoff_location Faker::Lorem.words
    daily_rate_cents 25000
  end
end    