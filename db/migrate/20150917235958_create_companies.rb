class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :trading_name
      t.string :website
      t.string :abn
      t.string :vendor_number
      t.datetime :archived_at
      t.timestamps null: false
    end
    add_index("companies", "name")
  end
end
