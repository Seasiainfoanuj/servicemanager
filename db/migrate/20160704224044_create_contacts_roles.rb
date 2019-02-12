class CreateContactsRoles < ActiveRecord::Migration
  def change
    create_table :contacts_roles, id: false do |t|
      t.belongs_to :user, index: true
      t.belongs_to :contact_role_type, index: true
    end
    add_index :contacts_roles, [:user_id, :contact_role_type_id], unique: true
  end
end

