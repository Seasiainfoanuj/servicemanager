class CreateEnquiryEmailUploads < ActiveRecord::Migration
  def change
    create_table :enquiry_email_uploads do |t|
      t.string :upload_file_name
      t.string :upload_content_type
      t.integer :upload_file_size
      t.integer :upload_updated_at
      t.references :enquiry, index: true, foreign_key: true
     
      t.timestamps null: false
    end
  end
end
