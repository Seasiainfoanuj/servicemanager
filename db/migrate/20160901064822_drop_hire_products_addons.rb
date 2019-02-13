class DropHireProductsAddons < ActiveRecord::Migration
  def change
    drop_table :hire_products_hire_addons, id: false do |t|
      t.belongs_to :hire_product, index: true
      t.belongs_to :hire_addon, index: true
    end
  end
end
