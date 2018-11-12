class AddDeliveryLocationToHireQuoteVehicles < ActiveRecord::Migration
  def change
    add_column :hire_quote_vehicles, :delivery_location, :string
  end
end
