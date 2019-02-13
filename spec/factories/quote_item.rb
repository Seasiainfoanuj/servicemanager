FactoryGirl.define do
  factory :quote_item do
    association :quote
    tax { Tax.first || create(:tax) }
    association :quote_item_type

    association :supplier, factory: [:user, :supplier]
    association :service_provider, factory: [:user, :service_provider]

    sequence(:name) { Faker::Lorem.word }
    description Faker::Lorem.paragraphs

    cost_cents Faker::Number.number(4)
    cost_currency Faker::Lorem.word

    buy_price_cents Faker::Number.number(4)
    buy_price_currency Faker::Lorem.word
    buy_price_tax { Tax.first || create(:tax) }

    quantity Faker::Number.number(2)
    position Faker::Number.number(2)

    hide_cost false
  end
end
