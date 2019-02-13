FactoryGirl.define do
  factory :off_hire_report do
    association :hire_agreement
    association :user
    odometer_reading Faker::Number.number(5)
    report_time Date.today
    notes_exterior Faker::Lorem.paragraphs
    notes_interior Faker::Lorem.paragraphs
    notes_other Faker::Lorem.paragraphs
    spare_tyre_check false
    tool_check false
    wheel_nut_indicator_check false
    triangle_stand_reflector_check false
    first_aid_kit_check false
    wheel_chock_check false
    jump_start_lead_check false
    fire_extinguisher_check false
    mine_flag_check false
    photo_check_front false
    photo_check_rear false
    photo_check_passenger_side false
    photo_check_driver_side false
    photo_check_fuel_gauge false
    photo_check_rego_label false
    photo_check_all_damages false
    photo_check_windscreen false
    fuel_litres Faker::Number.number(2)
    check_lights false
    check_horn false
    check_windscreen_washer_bottle false
    check_wiper_blades false
    check_service_sticker false
    check_windscreen_chips false
    check_vehicle_clean false
  end
end
