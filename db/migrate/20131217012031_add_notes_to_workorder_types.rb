class AddNotesToWorkorderTypes < ActiveRecord::Migration
  def change
    add_column :workorder_types, :notes, :text
  end
end
