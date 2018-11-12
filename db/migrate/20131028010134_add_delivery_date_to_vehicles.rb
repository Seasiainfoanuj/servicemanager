class AddDeliveryDateToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :delivery_date, :date
  end
end
