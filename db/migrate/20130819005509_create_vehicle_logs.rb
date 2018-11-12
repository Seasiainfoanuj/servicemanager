class CreateVehicleLogs < ActiveRecord::Migration
  def change
    create_table :vehicle_logs do |t|
      t.references :vehicle
      t.references :workorder
      t.string "uid", :limit => 25
      t.integer "service_provider_id"
      t.string "name"
      t.string "odemeter_reading"
      t.string "attachments"
      t.text "notes"
      t.timestamps
    end
    add_index("vehicle_logs", "uid")
    add_index("vehicle_logs", "vehicle_id")
    add_index("vehicle_logs", "workorder_id")
    add_index("vehicle_logs", "service_provider_id")
  end
end
