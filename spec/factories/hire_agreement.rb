FactoryGirl.define do
  factory :hire_agreement do
    association :type, factory: [:hire_agreement_type]
    association :vehicle
    association :customer, factory: [:user, :customer]
    association :manager, factory: [:user, :admin]
    association :quote
    association :invoice_company
    uid Faker::Number.number(5)
    status Faker::Lorem.word
    pickup_time Date.today
    return_time Date.today
    pickup_location Faker::Address.city
    return_location Faker::Address.city
    demurrage_start_time Date.today
    demurrage_end_time Date.today
    demurrage_rate Faker::Number.number(2)
    seating_requirement Faker::Number.number(2)
    daily_km_allowance Faker::Number.number(2)
    daily_rate Faker::Number.number(2)
    excess_km_rate Faker::Number.number(2)
    damage_recovery_fee Faker::Number.number(2)
    fuel_service_fee Faker::Number.number(2)
    details Faker::Lorem.paragraphs
  end
end
