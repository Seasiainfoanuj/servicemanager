class EnquiryEmailUpload < ActiveRecord::Base
  belongs_to :enquiry
  validates :enquiry_id, presence: true
  before_save :default_values

  has_attached_file :upload,
    :styles => {
      :small => "160x160>",
      :thumb => "100x100>",
      :pdf_thumbnail => ["", :jpg]
    }
  validates_attachment_size :upload, :less_than => 10.megabytes
  validates_attachment_content_type :upload, :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'application/pdf']
  include Rails.application.routes.url_helpers
  
  def default_values
    self.email_sent ||= true
  end

  def to_jq_upload
    {
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      "thumbnail_url" => upload.url(:small),
      "delete_url" => enquiry_email_upload_path(self),
      "delete_type" => "DELETE"
    }
  end
end


