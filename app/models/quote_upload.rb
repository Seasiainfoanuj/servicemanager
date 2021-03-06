class QuoteUpload < ActiveRecord::Base
  belongs_to :quote

  validates :quote_id, presence: true

  has_attached_file :upload,
    :styles => {
      :medium => "200x200>",
      :thumb => "100x100>",
      :pdf_thumbnail => ["", :jpg]
    }

  validates_attachment_size :upload, :less_than => 10.megabytes
  validates_attachment_content_type :upload, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      "thumbnail_url" => upload.url(:medium),
      "delete_url" => quote_upload_path(self),
      "delete_type" => "DELETE"
    }
  end
end
