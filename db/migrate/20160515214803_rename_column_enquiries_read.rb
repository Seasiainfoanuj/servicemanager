class RenameColumnEnquiriesRead < ActiveRecord::Migration
  def change
    rename_column :enquiries, :read, :seen
  end
end
