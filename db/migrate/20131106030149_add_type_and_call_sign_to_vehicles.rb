class AddTypeAndCallSignToVehicles < ActiveRecord::Migration
  def change
    add_column :vehicles, :class_type, :string
    add_column :vehicles, :call_sign, :string
  end
end
