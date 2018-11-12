class DropHireProductsProductTypes < ActiveRecord::Migration
  def change
    drop_table :hire_products_hire_product_types, id: false do |t|
      t.belongs_to :hire_product, index: true
      t.belongs_to :hire_product_type, index: true
    end
  end
end
