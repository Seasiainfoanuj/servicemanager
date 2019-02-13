class ChangeOdemeterToOdometer < ActiveRecord::Migration
  def change
    rename_column :vehicles, :odemeter_reading, :odometer_reading
    rename_column :vehicle_logs, :odemeter_reading, :odometer_reading
  end
end
