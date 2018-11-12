class SpInvoice < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :job, polymorphic: true
  belongs_to :workorder, :class_name => "Workorder",
                         :foreign_key => "job_id"
  belongs_to :build_order, :class_name => "BuildOrder",
                           :foreign_key => "job_id"
  belongs_to :off_hire_job, :class_name => "OffHireJob",
                            :foreign_key => "job_id"

  has_many :notes, as: :resource, :dependent => :destroy

  has_attached_file :upload,
    :styles => {
      :medium => "200x200>",
      :thumb => "100x100>",
      :pdf_thumbnail => ["", :jpg]
    }

  validates_attachment_size :upload, :less_than => 15.megabytes
  validates_attachment_content_type :upload, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'application/msword', 'text/plain', 'text/xml']

  validates :job_id, presence: true
  validates :job_type, presence: true

  attr_accessor :delete_upload
  before_validation { upload.clear if delete_upload == '1' }

  before_save :set_status

  STATUSES = ["awaiting invoice", "invoice received", "viewed", "processed"]

  def resource_name
    "SP Invoice #{invoice_number}"
  end  

  def resource_link
    desc = "Invoice #{invoice_number}"
    link = "<br><a href=#{UrlHelper.sp_invoice_url(self)}>#{UrlHelper.sp_invoice_url(self)}</a><br>".html_safe
    desc + link
  end

  private
    def set_status
      unless self.status == 'viewed' || self.status == 'processed'
        if self.upload.present?
          self.status = 'invoice received'
        else
          self.status = 'awaiting invoice'
        end
      end
    end
end
