class CreateVehicleUploads < ActiveRecord::Migration
  def change
    create_table :vehicle_uploads do |t|
      t.references :vehicle
      t.attachment :upload
    end
    add_index("vehicle_uploads", "vehicle_id")
  end
end
