class AddEngineNumberToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :engine_number, :string, limit: 50
  end
end
