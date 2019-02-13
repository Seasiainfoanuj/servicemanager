class AddErrorMethodToSystemErrors < ActiveRecord::Migration
  unless column_exists?  :system_errors, :error_method
    add_column :system_errors, :error_method, :string
  end
end
