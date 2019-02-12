class CreateVehicleScheduleViews < ActiveRecord::Migration
  def change
    create_table :vehicle_schedule_views do |t|
      t.belongs_to :vehicle, index: true
      t.belongs_to :schedule_view, index: true
      t.integer :position
      t.timestamps
    end
  end
end
