class CreateBuildSpecification < ActiveRecord::Migration
  def change
    create_table :build_specifications do |t|
      t.references :build, index: true
      t.integer :swing_type, default: 0
      t.integer :heating_source, default: 0
      t.integer :total_seat_count, default: 0
      t.integer :seating_type, default: 0
      t.integer :state_sign, default: 0
      t.text :paint
      t.text :other_seating
      t.text :surveillance_system
      t.text :comments
      t.boolean :lift_up_wheel_arches, default: false
      t.timestamps null: false
    end
  end
end
