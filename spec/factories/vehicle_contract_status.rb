FactoryGirl.define do
  factory :vehicle_contract_status do
    association :vehicle_contract
    association :changed_by, factory: [:user, :customer]
    name 'draft'
    signed_at_location_ip '123.456.78.901'
    status_timestamp Time.now
  end
end
