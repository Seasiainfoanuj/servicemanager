class CreateHireProductsProductTypes < ActiveRecord::Migration
  def change
    create_table :hire_products_hire_product_types, id: false do |t|
      t.belongs_to :hire_product, index: true
      t.belongs_to :hire_product_type, index: true
    end
    add_index :hire_products_hire_product_types, [:hire_product_id, :hire_product_type_id], unique: true, name: 'products_product_types_index'
  end
end
