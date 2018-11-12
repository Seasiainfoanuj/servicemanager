class AddEmailSentToEnquiryEmailUpload < ActiveRecord::Migration
  def change
    add_column :enquiry_email_uploads, :email_sent, :boolean, default: false
  end
end
