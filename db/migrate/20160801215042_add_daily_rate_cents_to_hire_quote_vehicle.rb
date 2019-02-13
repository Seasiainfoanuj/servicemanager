class AddDailyRateCentsToHireQuoteVehicle < ActiveRecord::Migration
  def change
    add_column :hire_quote_vehicles, :daily_rate_cents, :integer
  end
end
