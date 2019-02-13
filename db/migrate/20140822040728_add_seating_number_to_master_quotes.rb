class AddSeatingNumberToMasterQuotes < ActiveRecord::Migration
  def change
    add_column :master_quotes, :seating_number, :integer
  end
end
