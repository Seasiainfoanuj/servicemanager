class CreateVehicleModels < ActiveRecord::Migration
  def change
    create_table :vehicle_models do |t|
      t.references :vehicle_make
      t.string "name", :limit => 50
      t.integer "year"
    end
    add_index("vehicle_models", "vehicle_make_id")
  end
end
