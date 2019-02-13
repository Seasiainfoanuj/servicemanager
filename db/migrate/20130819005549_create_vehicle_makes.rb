class CreateVehicleMakes < ActiveRecord::Migration
  def change
    create_table :vehicle_makes do |t|
      t.string "name", :limit => 50
    end
  end
end
