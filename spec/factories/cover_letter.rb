FactoryGirl.define do
  factory :cover_letter do
    covering_subject  { HireQuote.first }
    title Faker::Lorem.word
    content Faker::Lorem.paragraph
  end
end