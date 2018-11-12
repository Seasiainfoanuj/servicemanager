class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.references :vehicle
      t.references :manager
      t.references :quote
      t.string "number", :limit => 25
      t.timestamps
    end
    add_index("builds", "vehicle_id")
    add_index("builds", "manager_id")
    add_index("builds", "quote_id")
  end
end
