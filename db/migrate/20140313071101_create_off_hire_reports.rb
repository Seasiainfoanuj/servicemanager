class CreateOffHireReports < ActiveRecord::Migration
  def change
    create_table :off_hire_reports do |t|
      t.references :hire_agreement, index: true
      t.references :user, index: true
      t.integer :odometer_reading
      t.datetime :report_time
      t.string :dropoff_person_first_name
      t.string :dropoff_person_last_name
      t.string :dropoff_person_phone
      t.string :dropoff_person_licence_number
      t.text :notes_exterior
      t.text :notes_interior
      t.text :notes_other
      t.boolean :spare_tyre_check
      t.boolean :tool_check
      t.boolean :wheel_nut_indicator_check
      t.boolean :triangle_stand_reflector_check
      t.boolean :first_aid_kit_check
      t.boolean :wheel_chock_check
      t.boolean :jump_start_lead_check
      t.boolean :fire_extinguisher_check
      t.boolean :mine_flag_check
      t.boolean :photo_check_front
      t.boolean :photo_check_rear
      t.boolean :photo_check_passenger_side
      t.boolean :photo_check_driver_side
      t.boolean :photo_check_fuel_gauge
      t.boolean :photo_check_rego_label
      t.boolean :photo_check_all_damages
      t.integer :fuel_litres
      t.timestamps
    end
  end
end
