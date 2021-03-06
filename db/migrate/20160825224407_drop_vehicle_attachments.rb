class DropVehicleAttachments < ActiveRecord::Migration
  def change
    drop_table :vehicle_attachments do |t|
      t.integer  :vehicle_id
      t.string   :mod_plate_file_name
      t.string   :mod_plate_content_type
      t.integer  :mod_plate_file_size
      t.datetime :mod_plate_updated_at
      t.string   :mod_certificate_file_name
      t.string   :mod_certificate_content_type
      t.integer  :mod_certificate_file_size
      t.datetime :mod_certificate_updated_at
      t.string   :rego_certificate_file_name
      t.string   :rego_certificate_content_type
      t.integer  :rego_certificate_file_size
      t.datetime :rego_certificate_updated_at
      t.string   :photo_front_file_name
      t.string   :photo_front_content_type
      t.integer  :photo_front_file_size
      t.datetime :photo_front_updated_at
      t.string   :photo_back_file_name
      t.string   :photo_back_content_type
      t.integer  :photo_back_file_size
      t.datetime :photo_back_updated_at
      t.string   :photo_left_file_name
      t.string   :photo_left_content_type
      t.integer  :photo_left_file_size
      t.datetime :photo_left_updated_at
      t.string   :photo_right_file_name
      t.string   :photo_right_content_type
      t.integer  :photo_right_file_size
      t.datetime :photo_right_updated_at
      t.string   :spec_sheet_file_name
      t.string   :spec_sheet_content_type
      t.integer  :spec_sheet_file_size
      t.datetime :spec_sheet_updated_at
      t.string   :vin_plate_file_name
      t.string   :vin_plate_content_type
      t.integer  :vin_plate_file_size
      t.datetime :vin_plate_updated_at
      t.string   :pre_delivery_sheet_file_name
      t.string   :pre_delivery_sheet_content_type
      t.integer  :pre_delivery_sheet_file_size
      t.datetime :pre_delivery_sheet_updated_at
      t.string   :bma_spec_sheet_file_name
      t.string   :bma_spec_sheet_content_type
      t.integer  :bma_spec_sheet_file_size
      t.datetime :bma_spec_sheet_updated_at
      t.string   :wheel_alignment_record_file_name
      t.string   :wheel_alignment_record_content_type
      t.integer  :wheel_alignment_record_file_size
      t.datetime :wheel_alignment_record_updated_at
      t.string   :ppsr_register_file_name
      t.string   :ppsr_register_content_type
      t.integer  :ppsr_register_file_size
      t.datetime :ppsr_register_updated_at
      t.string   :rigid_bus_inspection_sheet_file_name
      t.string   :rigid_bus_inspection_sheet_content_type
      t.integer  :rigid_bus_inspection_sheet_file_size
      t.datetime :rigid_bus_inspection_sheet_updated_at
    end
  end
end
