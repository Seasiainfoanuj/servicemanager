class AddUserEmailToSystemErrors < ActiveRecord::Migration
  unless column_exists? :system_errors, :user_email
    add_column :system_errors, :user_email, :string
  end
end
