class CreateMasterQuotes < ActiveRecord::Migration
  def change
    create_table :master_quotes do |t|
      t.belongs_to :master_quote_type, index: true
      t.string :vehicle_make
      t.string :vehicle_model
      t.string :name
      t.text :terms
      t.text :notes
      t.timestamps
    end
  end
end
