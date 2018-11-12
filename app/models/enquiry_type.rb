class EnquiryType < ActiveRecord::Base

  has_many :enquiries

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  def self.hire_enquiry
    EnquiryType.find_by(slug: 'hire')
  end

  def hire_enquiry?
    slug == 'hire'
  end
end
