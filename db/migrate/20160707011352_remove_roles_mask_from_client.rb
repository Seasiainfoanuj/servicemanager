class RemoveRolesMaskFromClient < ActiveRecord::Migration
  def up
    remove_column :clients, :roles_mask, :integer
  end

  def down
    add_column :clients, :roles_mask, :integer
  end
end
