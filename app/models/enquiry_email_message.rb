class EnquiryEmailMessage < ActiveRecord::Base
  belongs_to :enquiry
  belongs_to :email_message
end
