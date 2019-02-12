class CreateVehicles < ActiveRecord::Migration
  def change
    create_table :vehicles do |t|
      t.references :vehicle_model
      t.integer "supplier_id"
      t.integer "owner_id"
      t.string "build_number", :limit => 25
      t.string "stock_number", :limit => 25
      t.string "vin_number", :limit => 50
      t.string "vehicle_number", :limit => 50
      t.string "engine_number", :limit => 50
      t.string "transmission", :limit => 25
      t.string "location"
      t.string "books_and_keys"
      t.string "mod_plate"
      t.string "odemeter_reading"
      t.integer "seating_capacity"
      t.string "rego_number", :limit => 25
      t.date "rego_due_date"
      t.string "order_number"
      t.string "invoice_number"
      t.string "kit_number"
      t.text "notes"
      t.timestamps
    end
    add_index("vehicles", "vehicle_model_id")
    add_index("vehicles", "supplier_id")
    add_index("vehicles", "owner_id")
  end
end
