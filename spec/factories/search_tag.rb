FactoryGirl.define do
  factory :search_tag do
    tag_type 'hire_quote'
    sequence(:name) {|n| "#{Faker::Lorem.word}-#{n*10}" }
  end
end
