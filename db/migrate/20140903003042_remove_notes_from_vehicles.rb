class RemoveNotesFromVehicles < ActiveRecord::Migration
  def up
    remove_column :vehicles, :notes, :text
  end

  def down
    add_column :vehicles, :notes, :text
  end
end
