class AddDailyVehicleHireFeeCentsToHireProducts < ActiveRecord::Migration
  def change
    add_column :hire_products, :daily_rate_cents, :integer, default: 0
  end
end
