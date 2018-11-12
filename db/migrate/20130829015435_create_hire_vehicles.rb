class CreateHireVehicles < ActiveRecord::Migration
  def change
    create_table :hire_vehicles do |t|
      t.references :vehicle
      t.integer "daily_km_allowance"
      t.decimal "daily_rate", :precision => 8, :scale => 2
      t.decimal "excess_km_rate", :precision => 8, :scale => 2
      t.boolean "active", :default => false
      t.timestamps
    end
    add_index("hire_vehicles", "vehicle_id")
  end
end
