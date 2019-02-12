class CreateWorkorders < ActiveRecord::Migration
  def change
    create_table :workorders do |t|
      t.references :vehicle
      t.references :workorder_type
      t.string "uid", :limit => 25
      t.string "status", :limit => 25
      t.boolean "is_recurring", :default => false
      t.integer "recurring_period"
      t.integer "service_provider_id"
      t.integer "customer_id"
      t.integer "manager_id"
      t.datetime "sched_time"
      t.datetime "etc"
      t.text "details"
      t.timestamps
    end
    add_index("workorders", "uid")
    add_index("workorders", "vehicle_id")
    add_index("workorders", "workorder_type_id")
    add_index("workorders", "service_provider_id")
    add_index("workorders", "customer_id")
    add_index("workorders", "manager_id")
  end
end
