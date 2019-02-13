class CreateMasterQuoteTypes < ActiveRecord::Migration
  def change
    create_table :master_quote_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
