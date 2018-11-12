class AddTotalCentsToQuotes < ActiveRecord::Migration
  def change
    add_column :quotes, :total_cents, :integer
  end
end
