FactoryGirl.define do
  factory :stock_request do
    association :stock, factory: :stock
    association :invoice_company
    association :supplier, factory: [:user, :supplier]
    association :customer, factory: [:user, :customer]
    sequence(:uid) {|n| "SR-#{n}"}
    status Faker::Lorem.word
    vehicle_make Faker::Lorem.word
    vehicle_model Faker::Lorem.word
    transmission_type Faker::Lorem.word
    requested_delivery_date 20.days.from_now
    details Faker::Lorem.paragraph
  end
end
