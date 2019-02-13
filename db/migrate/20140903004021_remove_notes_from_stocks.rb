class RemoveNotesFromStocks < ActiveRecord::Migration
  def up
    remove_column :stocks, :notes, :text
  end

  def down
    add_column :stocks, :notes, :text
  end
end
