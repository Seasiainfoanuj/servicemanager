FactoryGirl.define do
  factory :hire_charge do
    association :hire_agreement
    tax { Tax.first || create(:tax) }
    name Faker::Lorem.word
    amount_cents Faker::Number.number(2)
    calculation_method Faker::Lorem.word
    quantity Faker::Number.number(1)
  end
end
