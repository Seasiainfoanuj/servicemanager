FactoryGirl.define do
  factory :address do
    address_type Address::POSTAL
    line_1 Faker::Address.street_address
    line_2 Faker::Address.secondary_address
    suburb Faker::Address.city
    state 'NSW'
    postcode '2001'
    country 'Australia'
  end
end
