class CreateVehicleModelsHireProductTypes < ActiveRecord::Migration
  def change
    create_table :vehicle_models_hire_product_types do |t|
      t.belongs_to :vehicle_model, index: true
      t.belongs_to :hire_product_type, index: true
    end
    add_index :vehicle_models_hire_product_types, [:vehicle_model_id, :hire_product_type_id], unique: true, name: 'vehicle_models_product_types_index'
  end
end
