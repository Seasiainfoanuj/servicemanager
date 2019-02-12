class EnquiryQuote < ActiveRecord::Base
   belongs_to :enquiry
   belongs_to :quote
end
