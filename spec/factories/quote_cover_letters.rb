FactoryGirl.define do
  factory :quote_cover_letter do
    association :quote
    title Faker::Lorem.word
    text Faker::Lorem.paragraph
  end
end
