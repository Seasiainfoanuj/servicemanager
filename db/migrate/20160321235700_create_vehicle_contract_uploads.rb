class CreateVehicleContractUploads < ActiveRecord::Migration
  def change
    create_table :vehicle_contract_uploads do |t|
      t.references :vehicle_contract, index: true
      t.references :uploaded_by, index: true
      t.string :uploaded_location_ip
      t.datetime :original_upload_time
      t.attachment :upload
      t.timestamps null: false
    end
  end
end
