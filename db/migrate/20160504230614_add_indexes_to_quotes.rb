class AddIndexesToQuotes < ActiveRecord::Migration
  def change
    add_index :quotes, :id
    add_index :quotes, :number
    add_index :quotes, :status
  end
end
