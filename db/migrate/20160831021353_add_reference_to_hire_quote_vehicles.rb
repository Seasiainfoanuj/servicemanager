class AddReferenceToHireQuoteVehicles < ActiveRecord::Migration
  def change
    add_reference :hire_quote_vehicles, :vehicle_model, index: true
    remove_index :hire_quote_vehicles, :hire_product_id
  end
end
