class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.references :vehicle_model
      t.integer "supplier_id"
      t.string "stock_number", :limit => 25
      t.string "vin_number", :limit => 50
      t.string "transmission", :limit => 25
      t.string "location"
      t.string "books_and_keys"
      t.text "notes"
      t.timestamps
    end
    add_index("stocks", "vehicle_model_id")
    add_index("stocks", "supplier_id")
  end
end
