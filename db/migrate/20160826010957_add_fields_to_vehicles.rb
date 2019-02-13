class AddFieldsToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :fuel_type, :string, default: 'diesel'
    add_column :vehicles, :usage_status, :string, default: 'not ready'
    add_column :vehicles, :operational_status, :string, default: 'roadworthy'
    add_column :vehicles, :tags, :string
    add_column :vehicles, :model_year, :integer
  end
end
