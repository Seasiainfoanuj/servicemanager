FactoryGirl.define do
  factory :sales_order_milestone do
    association :sales_order
    milestone_date Time.now
    description Faker::Lorem.words
    completed false
  end
end
