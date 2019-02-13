class AddAbnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :abn, :string
  end
end
