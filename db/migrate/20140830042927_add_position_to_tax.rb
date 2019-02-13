class AddPositionToTax < ActiveRecord::Migration
  def change
    add_column :taxes, :position, :integer
  end
end
