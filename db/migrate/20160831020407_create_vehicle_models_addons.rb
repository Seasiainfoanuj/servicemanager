class CreateVehicleModelsAddons < ActiveRecord::Migration
  def change
    create_table :vehicle_models_addons do |t|
      t.belongs_to :vehicle_model, index: true
      t.belongs_to :hire_addon, index: true
    end
    add_index :vehicle_models_addons, [:vehicle_model_id, :hire_addon_id], unique: true, name: 'models_addons_index'
  end
end
