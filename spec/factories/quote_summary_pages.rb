FactoryGirl.define do
  factory :quote_summary_page do
    association :quote
    text Faker::Lorem.words
  end
end
