class ChangeVehicleLogNotesToDetails < ActiveRecord::Migration
  def change
    rename_column :vehicle_logs, :notes, :details
  end
end
