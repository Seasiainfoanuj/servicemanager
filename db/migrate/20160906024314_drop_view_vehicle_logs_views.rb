class DropViewVehicleLogsViews < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS vehicle_logs_views;"
  end

  def down
    execute "DROP VIEW IF EXISTS vehicle_logs_views;"
  end
end
