class CreateStockRequests < ActiveRecord::Migration
  def change
    create_table :stock_requests do |t|
      t.references :invoice_company, index: true
      t.references :supplier, index: true
      t.references :customer, index: true
      t.references :stock, index: true
      t.string "uid", :limit => 25
      t.string "status", :limit => 25
      t.string :vehicle_make
      t.string :vehicle_model
      t.string :transmission_type
      t.date :requested_delivery_date
      t.text :details
      t.timestamps
    end
    add_index("stock_requests", "uid")
  end
end
