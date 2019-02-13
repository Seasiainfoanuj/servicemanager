class AddTransmissionTypeToMasterQuotes < ActiveRecord::Migration
  def change
    add_column :master_quotes, :transmission_type, :string
  end
end
