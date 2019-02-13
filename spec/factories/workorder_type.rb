FactoryGirl.define do
  factory :workorder_type do
    name Faker::Lorem.word
    label_color "#" + ((0..9).to_a + ('a'..'f').to_a).shuffle.first(6).join
    notes Faker::Lorem.paragraphs
  end
end
