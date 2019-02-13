class CreatePoRequests < ActiveRecord::Migration
  def change
    create_table :po_requests do |t|
      t.belongs_to :service_provider, index: true
      t.belongs_to :vehicle, index: true
      t.string :uid
      t.string :vehicle_make
      t.string :vehicle_model
      t.string :vehicle_vin_number
      t.datetime :sched_time
      t.datetime :etc
      t.boolean :read
      t.boolean :flagged
      t.string :status
      t.text :details
      t.timestamps
    end
  end
end
