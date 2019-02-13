class AddUidToEmailMessages < ActiveRecord::Migration
  def change
    add_column :email_messages, :uid, :string
  end
end
