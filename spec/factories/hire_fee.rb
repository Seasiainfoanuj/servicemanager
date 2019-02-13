FactoryGirl.define do
  factory :hire_fee do
    association :fee_type, factory: :fee_type
    chargeable { HireQuoteVehicle.first || create(:hire_quote_vehicle) }
    fee_cents 120
  end
end

