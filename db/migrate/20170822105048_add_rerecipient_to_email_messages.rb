class AddRerecipientToEmailMessages < ActiveRecord::Migration
  def change
    add_column :email_messages, :rerecipient, :string
  end
end
