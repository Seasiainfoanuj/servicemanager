class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer "sender_id"
      t.integer "recipient_id"
      t.integer "workorder_id"
      t.integer "hire_agreement_id"
      t.integer "quote_id"
      t.text "comments"
      t.timestamps
    end
  end
end
