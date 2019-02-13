class AddEtaToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :eta, :datetime
  end
end
