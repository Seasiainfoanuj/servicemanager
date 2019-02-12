FactoryGirl.define do
  factory :fee_type do
    category 'vehicle'
    sequence(:name) {|n| "Fee-#{n}"}
    charge_unit 'per_km'
  end
end
  