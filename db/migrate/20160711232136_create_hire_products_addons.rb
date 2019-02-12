class CreateHireProductsAddons < ActiveRecord::Migration
  def change
    create_table :hire_products_hire_addons, id: false do |t|
      t.belongs_to :hire_product, index: true
      t.belongs_to :hire_addon, index: true
    end
    add_index :hire_products_hire_addons, [:hire_product_id, :hire_addon_id], unique: true, name: 'products_addons_index'
  end
end
