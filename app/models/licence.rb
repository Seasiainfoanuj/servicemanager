class Licence < ActiveRecord::Base
  belongs_to :user

  validates :user_id, presence: true

  has_attached_file :upload,
    :styles => {
      :large => "200x200>",
      :pdf_thumbnail => ["", :jpg]
    },
    :default_url => "/images/:style/licence.png"

  validates_attachment_size :upload, :less_than => 10.megabytes
  validates_attachment_content_type :upload, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf']

  def expiry_date_field
    expiry_date.strftime("%d/%m/%Y") if expiry_date.present?
  end

  def expiry_date_field=(date)
    self.expiry_date = Time.zone.parse(date)
  end
end
