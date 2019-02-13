# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :po_request do
    association :vehicle
    association :service_provider, factory: [:user, :service_provider]
    sequence(:uid) {|n| "SR-#{n}"}
    vehicle_make Faker::Lorem.word
    vehicle_model Faker::Lorem.word
    sequence(:vehicle_vin_number) {|n| Faker::Number.number(17) }
    sched_time 10.days.from_now
    etc 20.days.from_now
    read false
    flagged false
    status Faker::Lorem.word
    details Faker::Lorem.words
  end
end
