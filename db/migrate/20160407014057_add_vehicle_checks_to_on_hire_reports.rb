class AddVehicleChecksToOnHireReports < ActiveRecord::Migration
  def change
    add_column :on_hire_reports, :check_lights, :boolean, default: false
    add_column :on_hire_reports, :check_horn, :boolean, default: false
    add_column :on_hire_reports, :check_windscreen_washer_bottle, :boolean, default: false
    add_column :on_hire_reports, :check_wiper_blades, :boolean, default: false
    add_column :on_hire_reports, :check_service_sticker, :boolean, default: false
    add_column :on_hire_reports, :check_windscreen_chips, :boolean, default: false
    add_column :on_hire_reports, :check_vehicle_clean, :boolean, default: false
  end
end
