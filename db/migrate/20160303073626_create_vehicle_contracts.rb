class CreateVehicleContracts < ActiveRecord::Migration
  def change
    create_table :vehicle_contracts do |t|
      t.string :uid
      t.references :customer, index: true
      t.references :quote, index: true
      t.references :vehicle, index: true
      t.references :invoice_company
      t.references :manager
      t.references :allocated_stock
      t.money :deposit_received
      t.date :deposit_received_date
      t.string :current_status
      t.text :special_conditions

      t.timestamps null: false
    end
    
    add_index("vehicle_contracts", "uid")
  end
end
