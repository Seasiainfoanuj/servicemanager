class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.integer "customer_id"
      t.integer "manager_id"
      t.string "number", :limit => 25
      t.string "po_number", :limit => 25
      t.date "date"
      t.decimal "discount", :precision => 6, :scale => 5
      t.string "status", :limit => 25
      t.text "terms"
      t.text "notes"
      t.timestamps
    end
    add_index(:quotes, "customer_id")
    add_index(:quotes, "manager_id")
  end
end
