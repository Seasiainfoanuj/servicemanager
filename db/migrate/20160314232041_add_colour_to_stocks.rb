class AddColourToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :colour, :string
  end
end
