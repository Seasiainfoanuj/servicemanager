class AddLicenseAndExcludeToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :license_required, :string
    add_column :vehicles, :exclude_from_schedule, :boolean
  end
end
