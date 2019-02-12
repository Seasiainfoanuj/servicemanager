FactoryGirl.define do
  factory :saved_quote_item do
    association :tax
    name Faker::Lorem.words
    description Faker::Lorem.paragraphs
    cost_cents Faker::Number.number(4)
    cost_currency Faker::Lorem.word
    quantity Faker::Number.number(1)
  end
end