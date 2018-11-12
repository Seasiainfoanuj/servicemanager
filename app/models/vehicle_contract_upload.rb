class VehicleContractUpload < ActiveRecord::Base
  belongs_to :vehicle_contract
  belongs_to :uploaded_by, class_name: 'User'

  validates :vehicle_contract_id, presence: true
  validates :uploaded_by_id, presence: true

  has_attached_file :upload,
    :styles => {
      :large => "300x300>",
      :pdf_thumbnail => ["", :jpg]
    }

  validates_attachment_size :upload, :less_than => 10.megabytes
  validates_attachment_content_type :upload, :content_type => ['image/jpeg', 'image/png', 'application/pdf']

  after_initialize :set_default_values

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

  def original_upload_time_display
    original_upload_time.strftime("%d/%m/%Y %R")
  end

  private

    def set_default_values
      self.original_upload_time = Time.now
    end

end