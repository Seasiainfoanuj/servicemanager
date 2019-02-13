class EnquirySearch
  include ActiveModel::Model
  attr_accessor :uid, :enquirer_name, :manager_name, :company_name, :enquiry_type, :enquiry_status,
                :show_all, :sort_field, :direction, :per_page, :defaults 
  attr_reader :filtered_user_id, :current_user_id

  def initialize(attributes = {})
    set_defaults
    @uid = attributes[:uid]
    @enquirer_name = attributes[:enquirer_name]
    @manager_name = attributes[:manager_name]
    @company_name = attributes[:company_name]
    @enquiry_type = attributes[:enquiry_type]
    @enquiry_status = attributes[:enquiry_status]
    @show_all = attributes[:show_all]
    @sort_field = attributes[:sort_field] || defaults[:sort_field]
    @direction = attributes[:direction] || defaults[:direction]
    @per_page = attributes[:per_page] || defaults[:per_page]
  end

  def set_defaults
    @defaults = {}
    @defaults[:sort_field] = 'Enquiry date'
    @defaults[:direction] = 'Descending'
    @defaults[:per_page] = '10'
  end

end
