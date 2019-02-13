class NoteUpload < ActiveRecord::Base
  belongs_to :note

  has_attached_file :upload,
    :styles => {
      :medium => "200x200>",
      :thumb => "100x100>",
      :pdf_thumbnail => ["", :jpg]
    }

  validates_attachment_size :upload, :less_than => 15.megabytes
  validates_attachment_content_type :upload, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml']
end
