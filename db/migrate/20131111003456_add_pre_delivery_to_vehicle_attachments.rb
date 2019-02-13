class AddPreDeliveryToVehicleAttachments < ActiveRecord::Migration
  def change
    add_attachment :vehicle_attachments, :pre_delivery_sheet
  end
end
