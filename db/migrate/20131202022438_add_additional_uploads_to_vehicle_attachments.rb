class AddAdditionalUploadsToVehicleAttachments < ActiveRecord::Migration
  def change
    add_attachment :vehicle_attachments, :bma_spec_sheet
    add_attachment :vehicle_attachments, :wheel_alignment_record
    add_attachment :vehicle_attachments, :ppsr_register
  end
end
