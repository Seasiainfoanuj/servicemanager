class AddInternationalToMasterQuotes < ActiveRecord::Migration
  unless column_exists?  :master_quotes, :international
    add_column :master_quotes, :international, :string
  end
end
