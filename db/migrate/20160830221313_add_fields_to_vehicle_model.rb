class AddFieldsToVehicleModel < ActiveRecord::Migration
  def change
    add_column :vehicle_models, :number_of_seats, :integer, default: 0
    add_column :vehicle_models, :tags, :string
    add_column :vehicle_models, :daily_rate_cents, :integer, default: 0
    add_column :vehicle_models, :license_type, :string
    add_column :vehicle_models, :created_at, :datetime, null: false
    add_column :vehicle_models, :updated_at, :datetime, null: false
  end
end
