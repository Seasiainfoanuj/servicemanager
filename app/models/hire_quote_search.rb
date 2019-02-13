class HireQuoteSearch
  include ActiveModel::Model
  attr_accessor :reference, :customer_name, :manager_name, :company_name, :status, :tags,
                :show_all, :sort_field, :direction, :per_page, :defaults

  def initialize(attributes = {})
    set_defaults
    @reference = attributes[:reference]
    @customer_name = attributes[:customer_name]
    @manager_name = attributes[:manager_name]
    @company_name = attributes[:company_name]
    @status = attributes[:status]
    @tags = attributes[:tags]
    @show_all = attributes[:show_all]
    @sort_field = attributes[:sort_field] || defaults[:sort_field]
    @direction = attributes[:direction] || defaults[:direction]
    @per_page = attributes[:per_page] || defaults[:per_page]
  end
  
  def set_defaults
    @defaults = {}
    @defaults[:sort_field] = 'Hire Status Date'
    @defaults[:direction] = 'Descending'
    @defaults[:per_page] = '10'
  end

end    