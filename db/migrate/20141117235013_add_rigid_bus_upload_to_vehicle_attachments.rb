class AddRigidBusUploadToVehicleAttachments < ActiveRecord::Migration
  def change
    add_attachment :vehicle_attachments, :rigid_bus_inspection_sheet
  end
end
