class CreateEnquiryEmailMessages < ActiveRecord::Migration
  def change
    create_table :enquiry_email_messages do |t|
      t.references :enquiry, index: true, foreign_key: true
      t.references :email_message, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
