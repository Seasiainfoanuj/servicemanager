class RemoveHireSettings < ActiveRecord::Migration
  def up
    drop_table :hire_settings
  end

  def down
    create_table :hire_settings do |t|
      t.decimal "damage_recovery_fee", :precision => 8, :scale => 2
      t.decimal "fuel_service_fee", :precision => 8, :scale => 2
      t.timestamps
    end
  end
end
