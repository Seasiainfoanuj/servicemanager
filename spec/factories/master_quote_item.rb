# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :master_quote_item do
    name Faker::Lorem.word
    description Faker::Lorem.paragraphs

    cost_cents Faker::Number.number(4)
    cost_currency Faker::Lorem.word
    association :quote_item_type
    cost_tax { Tax.first || create(:tax) }

    buy_price_cents Faker::Number.number(4)
    buy_price_currency Faker::Lorem.word
    buy_price_tax { Tax.first || create(:tax) }

    association :supplier, factory: [:user, :supplier]
    association :service_provider, factory: [:user, :service_provider]

    quantity Faker::Number.number(1)

    after(:create) do |master_quote_item|
      master_quote_item.master_quotes << FactoryGirl.build(:master_quote)
    end
  end
end
