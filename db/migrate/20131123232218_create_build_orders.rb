class CreateBuildOrders < ActiveRecord::Migration
  def change
    create_table :build_orders do |t|
      t.references :build
      t.references :service_provider
      t.references :manager
      t.string "name"
      t.string "uid", :limit => 25
      t.string "status", :limit => 25
      t.datetime "sched_time"
      t.datetime "etc"
      t.text "details"
      t.text "service_provider_notes"
      t.timestamps
    end
    add_index("build_orders", "build_id")
    add_index("build_orders", "service_provider_id")
    add_index("build_orders", "manager_id")
  end
end
