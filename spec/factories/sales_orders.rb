FactoryGirl.define do
  factory :sales_order do
    sequence(:number) {|n| "#{n}" }
    order_date Date.today
    association :quote
    association :build
    deposit_required_cents Faker::Number.number(1)
    deposit_received false
    association :customer, factory: [:user, :customer]
    association :manager, factory: [:user, :admin]
    association :invoice_company
    details Faker::Lorem.paragraphs
  end
end
