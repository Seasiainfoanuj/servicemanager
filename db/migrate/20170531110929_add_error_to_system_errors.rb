class AddErrorToSystemErrors < ActiveRecord::Migration
  unless column_exists? :system_errors, :error
    add_column :system_errors, :error, :string
  end
end
