class CreateHireAgreements < ActiveRecord::Migration
  def change
    create_table :hire_agreements do |t|
      t.references :vehicle
      t.integer "customer_id"
      t.integer "manager_id"
      t.string "uid", :limit => 25
      t.string "status", :limit => 25
      t.string "driver_license_number"
      t.string "driver_license_type"
      t.string "driver_license_state_of_issue"
      t.datetime "driver_license_expiry"
      t.datetime "driver_dob"
      t.datetime "pickup_time"
      t.datetime "return_time"
      t.string "pickup_location"
      t.string "return_location"
      t.integer "seating_requirement"
      t.integer "km_out"
      t.integer "km_in"
      t.integer "fuel_in"
      t.integer "daily_km_allowance"
      t.decimal "daily_rate", :precision => 8, :scale => 2
      t.decimal "excess_km_rate", :precision => 8, :scale => 2
      t.decimal "damage_recovery_fee", :precision => 8, :scale => 2
      t.decimal "fuel_service_fee", :precision => 8, :scale => 2
      t.text "notes"
      t.timestamps
    end
    add_index("hire_agreements", "uid")
    add_index("hire_agreements", "vehicle_id")
    add_index("hire_agreements", "customer_id")
    add_index("hire_agreements", "manager_id")
  end
end
