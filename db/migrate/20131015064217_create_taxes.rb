class CreateTaxes < ActiveRecord::Migration
  def change
    create_table :taxes do |t|
      t.string "name", :limit => 25
      t.decimal "rate", :precision => 6, :scale => 5
      t.string "number", :limit => 25
      t.timestamps
    end
  end
end
