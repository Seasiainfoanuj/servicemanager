class CreateHireFees < ActiveRecord::Migration
  def change
    create_table :hire_fees do |t|
      t.references :fee_type
      t.references :chargeable, polymorphic: true
      t.integer :fee_cents

      t.timestamps null: false
    end
  end
end
