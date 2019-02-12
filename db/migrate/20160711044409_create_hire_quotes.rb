class CreateHireQuotes < ActiveRecord::Migration
  def change
    create_table :hire_quotes do |t|
      t.string :uid
      t.references :customer, index: true
      t.references :manager, index: true
      t.references :enquiry, index: true
      t.integer :version, default: 1
      t.date :start_date
      t.string :status
      t.datetime :status_date
      t.datetime :last_viewed
      t.string :tags

      t.timestamps null: false
    end
    add_index :hire_quotes, :tags
    add_index :hire_quotes, [:uid, :version], unique: true
  end
end
