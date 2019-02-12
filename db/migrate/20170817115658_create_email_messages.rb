class CreateEmailMessages < ActiveRecord::Migration
  def change
    create_table :email_messages do |t|
      t.string :message

      t.timestamps null: false
    end
  end
end
