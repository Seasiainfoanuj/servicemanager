class HireAgreementTypeUpload < ActiveRecord::Base
  belongs_to :hire_agreement_type

  validates :hire_agreement_type_id, presence: true

  has_attached_file :upload,
    :styles => {
      :medium => "200x200>",
      :thumb => "100x100>",
      :pdf_thumbnail => ["", :jpg]
    }

  validates_attachment_size :upload, :less_than => 15.megabytes
  validates_attachment_content_type :upload, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml']

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      "thumbnail_url" => upload.url(:medium),
      "delete_url" => hire_agreement_type_upload_path(self),
      "delete_type" => "DELETE"
    }
  end
end
