FactoryGirl.define do
  factory :vehicle_log do
    association :vehicle
    association :workorder
    association :service_provider, factory: [:user, :service_provider]
    name Faker::Lorem.word + Faker::Number.number(2)
    sequence(:uid) {|n| "HJ-#{n}"}
    odometer_reading Faker::Number.number(4)
    # TO BE DEPRECIATED attachments
    details Faker::Lorem.words
    flagged true
  end
end
