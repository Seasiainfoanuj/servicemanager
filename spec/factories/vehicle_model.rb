FactoryGirl.define do
  factory :vehicle_model do
    association :make, factory: [:vehicle_make]
    sequence(:name) {|n| "Model-#{n}"}
    number_of_seats 18
    daily_rate_cents 4900
    license_type 'MR'
  end
end