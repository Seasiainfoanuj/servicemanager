class AddFlaggedToVehicleLog < ActiveRecord::Migration
  def change
    add_column :vehicle_logs, :flagged, :boolean
  end
end
