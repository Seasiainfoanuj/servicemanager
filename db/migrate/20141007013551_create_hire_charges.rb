class CreateHireCharges < ActiveRecord::Migration
  def change
    create_table :hire_charges do |t|
      t.references :hire_agreement, index: true
      t.references :tax, index: true
      t.string :name
      t.money :amount
      t.string :calculation_method
      t.integer :quantity
      t.timestamps
    end
  end
end
