FactoryGirl.define do
  factory :hire_quote_addon do
    association :hire_addon
    association :hire_quote_vehicle
    hire_price_cents 55400
  end
end