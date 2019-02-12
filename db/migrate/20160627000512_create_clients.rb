class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :reference_number
      t.string :client_type
      t.integer :roles_mask
      t.references :user, index: true
      t.references :company, index: true
      t.datetime :archived_at
      t.timestamps null: false
    end
    add_index("clients", "reference_number")
  end
end
