class CreateHireProducts < ActiveRecord::Migration
  def change
    create_table :hire_products do |t|
      t.references :vehicle_make, index: true
      t.string :model_name
      t.integer :number_of_seats, default: 0
    end
    add_index :hire_products, [:vehicle_make_id, :model_name], name: :idx_hire_product_on_make_model
  end
end
