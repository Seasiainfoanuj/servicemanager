class CreateVehicleContractStatuses < ActiveRecord::Migration
  def change
    create_table :vehicle_contract_statuses do |t|
      t.references :vehicle_contract, index: true
      t.references :changed_by, index: true
      t.string :name
      t.string :signed_at_location_ip
      t.datetime :status_timestamp
    end
  end
end
