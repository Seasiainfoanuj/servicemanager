FactoryGirl.define do
  factory :build_specification do
    association :build
    swing_type BuildSpecification::IN_SWING
    paint Faker::Lorem.paragraphs.join(" ")
    heating_source BuildSpecification::DIESEL_HEATING_UNIT
    total_seat_count 32
    seating_type BuildSpecification::OTHER_SEATING
    other_seating Faker::Lorem.paragraphs.join(" ")
    state_sign BuildSpecification::NOT_APPLICABLE
    surveillance_system Faker::Lorem.paragraphs.join(" ")
    lift_up_wheel_arches true
    comments Faker::Lorem.paragraphs
  end
end