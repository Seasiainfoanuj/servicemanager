class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notifiable, polymorphic: true, index: true
      t.references :notification_type, index: true
      t.references :invoice_company, index: true
      t.references :owner, index: true
      t.references :completed_by
      t.date :due_date
      t.date :completed_date
      t.boolean :document_uploaded, default: false
      t.text :email_message
      t.text :recipients
      t.boolean :send_emails, default: false
      t.text :comments
      t.datetime :archived_at
      t.timestamps null: false
    end
    add_index("notifications", "due_date")
    add_index("notifications", "completed_date")
  end
end
