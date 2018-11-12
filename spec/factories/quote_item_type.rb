FactoryGirl.define do
  factory :quote_item_type do
    sequence(:name) {|n| "Item type #{n}" }
    sort_order Faker::Number.number(1)
    allow_many_per_quote true
    taxable 1
  end
end
