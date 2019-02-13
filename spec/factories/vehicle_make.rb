FactoryGirl.define do
  factory :vehicle_make do
    sequence(:name) {|n| "Make-#{n}"}
  end
end