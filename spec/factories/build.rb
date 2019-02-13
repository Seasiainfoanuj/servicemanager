FactoryGirl.define do
  factory :build do
    association :vehicle
    association :manager, factory: [:user, :admin]
    association :quote
    association :invoice_company, factory: :invoice_company
    sequence(:number) {|n| "MA-#{n}"}
  end
end
