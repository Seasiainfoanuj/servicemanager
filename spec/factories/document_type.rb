FactoryGirl.define do
  factory :document_type do
    sequence(:name) {|n| "#{Faker::Lorem.word}-#{n*100}" }
    label_color "#" + ((0..9).to_a + ('a'..'f').to_a).shuffle.first(6).join
  end
end