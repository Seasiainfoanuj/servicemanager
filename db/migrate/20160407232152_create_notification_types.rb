class CreateNotificationTypes < ActiveRecord::Migration
  def change
    create_table :notification_types do |t|
      t.string  :resource_name
      t.string  :event_name
      t.boolean :recurring, default: false
      t.integer :recur_period_days, default: 0
      t.boolean :emails_required, default: false
      t.boolean :upload_required, default: true
      t.string :resource_document_type
      t.string :label_color
      t.text :notify_periods
      t.text :default_message
      t.timestamps null: false
    end
  end
end
