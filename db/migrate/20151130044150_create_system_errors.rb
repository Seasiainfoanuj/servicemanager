class CreateSystemErrors < ActiveRecord::Migration
  def change
    create_table :system_errors do |t|
      t.integer :resource_type, default: 0
      t.references :actioned_by
      t.integer :error_status, default: 0
      t.text    :description

      t.timestamps null: false
    end
  end
end
