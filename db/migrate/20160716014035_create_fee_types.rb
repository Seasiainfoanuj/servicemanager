class CreateFeeTypes < ActiveRecord::Migration
  def change
    create_table :fee_types do |t|
      t.string :category
      t.string :name
      t.string :charge_unit
    end
    add_index :fee_types, :name, unique: true
  end
end
