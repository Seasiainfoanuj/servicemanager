FactoryGirl.define do
  factory :vehicle_schedule_view do
    association :vehicle
    association :schedule_view
    position 1
  end
end
