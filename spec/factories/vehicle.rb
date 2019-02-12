FactoryGirl.define do
  factory :vehicle do
    association :model, factory: [:vehicle_model]
    model_year 2013
    supplier { User.supplier.first || create(:user, :supplier) }
    owner    { User.customer.first || create(:user, :customer) }
    sequence(:build_number) {|n| "BUILD-#{n}" }
    sequence(:stock_number) {|n| "STOCK-#{n}" }
    sequence(:vin_number) {|n| Faker::Number.number(17) }
    sequence(:vehicle_number) {|n| "VEHICLE-#{n}" }
    engine_number Faker::Number.number(17)
    transmission 'Automatic'
    mod_plate Faker::Lorem.words
    odometer_reading Faker::Number.number(5)
    seating_capacity Faker::Number.number(2)
    sequence(:rego_number) {|n| "REGO-#{n}" }
    rego_due_date Date.today
    order_number Faker::Number.number(5)
    invoice_number Faker::Number.number(5)
    sequence(:kit_number) {|n| "KIT-#{n}" }
    license_required Faker::Lorem.words
    exclude_from_schedule false
    delivery_date Date.today
    class_type Faker::Lorem.words
    call_sign Faker::Lorem.word
    body_type 'Bus'
    build_date Date.today
    colour Faker::Commerce.color
    engine_type Faker::Lorem.word
    status 'available'
    status_date Date.today
  end
end
