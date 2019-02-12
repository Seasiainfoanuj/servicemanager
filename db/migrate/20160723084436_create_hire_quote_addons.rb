class CreateHireQuoteAddons < ActiveRecord::Migration
  def change
    create_table :hire_quote_addons do |t|
      t.belongs_to :hire_addon, index: true
      t.belongs_to :hire_quote_vehicle, index: true
      t.integer :hire_price_cents, default: 0

      t.timestamps null: false
    end
  end
end
