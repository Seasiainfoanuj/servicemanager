FactoryGirl.define do
  factory :master_quote_summary_page do
    association :master_quote
    text Faker::Lorem.words
  end
end
