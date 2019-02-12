class CreateWorkorderTypes < ActiveRecord::Migration
  def change
    create_table :workorder_types do |t|
      t.string "name"
      t.string "label_color"
    end
  end
end
