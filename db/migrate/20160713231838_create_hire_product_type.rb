class CreateHireProductType < ActiveRecord::Migration
  def change
    create_table :hire_product_types do |t|
      t.string :name
    end
  end
end
