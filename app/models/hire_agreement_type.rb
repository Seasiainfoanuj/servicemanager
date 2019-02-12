class HireAgreementType < ActiveRecord::Base
  has_many :hire_agreements
  has_many :uploads, :class_name => "HireAgreementTypeUpload"

  accepts_nested_attributes_for :uploads, allow_destroy: true
end
