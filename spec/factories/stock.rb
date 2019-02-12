FactoryGirl.define do
  factory :stock do
    association :model, factory: [:vehicle_model]
    association :supplier, factory: [:user, :supplier]
    sequence(:stock_number) {|n| "STOCK-#{n}" }
    sequence(:vin_number) {|n| Faker::Lorem.characters(17) }
    engine_number Faker::Lorem.characters(20).upcase
    transmission 'Automatic'
    eta Date.today
    colour 'Blue'
  end
end
