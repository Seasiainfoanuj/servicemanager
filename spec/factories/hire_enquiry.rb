FactoryGirl.define do
  factory :hire_enquiry do
    association :enquiry, factory: [:enquiry]
    hire_start_date Date.today + 5.days
    duration_unit 'weeks'
    units 3
    number_of_vehicles 1
    delivery_required true
    delivery_location Faker::Lorem.words
    minimum_seats 30
    special_requirements Faker::Lorem.paragraph
  end
end  