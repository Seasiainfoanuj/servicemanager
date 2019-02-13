class CreateHireQuoteVehicles < ActiveRecord::Migration
  def change
    create_table :hire_quote_vehicles do |t|
      t.references :hire_quote, index: true
      t.references :hire_product, index: true
      t.date :start_date
      t.date :end_date
      t.boolean :ongoing_contract, default: false
      t.boolean :delivery_required, default: false
      t.boolean :demobilisation_required, default: false
      t.string :pickup_location
      t.string :dropoff_location
    end
  end
end
