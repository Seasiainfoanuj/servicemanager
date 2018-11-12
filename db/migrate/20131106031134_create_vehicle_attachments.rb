class CreateVehicleAttachments < ActiveRecord::Migration
  def change
    create_table :vehicle_attachments do |t|
      t.references :vehicle
      t.attachment :mod_plate
      t.attachment :mod_certificate
      t.attachment :rego_certificate
      t.attachment :photo_front
      t.attachment :photo_back
      t.attachment :photo_left
      t.attachment :photo_right
      t.attachment :spec_sheet
      t.attachment :vin_plate
    end
    add_index(:vehicle_attachments, "vehicle_id")
  end
end
