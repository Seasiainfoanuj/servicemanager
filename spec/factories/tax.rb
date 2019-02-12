FactoryGirl.define do
  factory :tax do
    name "GST"
    rate 0.10
    number Faker::Number.number(4)
    position Faker::Number.number(2)
  end
end
