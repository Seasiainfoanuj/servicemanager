class CreateHireAddons < ActiveRecord::Migration
  def change
    create_table :hire_addons do |t|
      t.string :addon_type
      t.string :model_name
      t.integer :hire_price_cents
      t.string :billing_frequency

      t.timestamps null: false
    end
    add_index :hire_addons, :model_name, unique: true
  end
end
