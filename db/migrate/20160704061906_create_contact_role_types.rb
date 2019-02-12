class CreateContactRoleTypes < ActiveRecord::Migration
  def change
    create_table :contact_role_types do |t|
      t.string :name
    end
  end
end
