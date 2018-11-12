class AddStatusToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :body_type, :string
    add_column :vehicles, :build_date, :date
    add_column :vehicles, :colour, :string
    add_column :vehicles, :engine_type, :string
    add_column :vehicles, :status, :string
    add_column :vehicles, :status_date, :date
  end
end
