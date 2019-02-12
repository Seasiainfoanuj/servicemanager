class QuoteSearch
  include ActiveModel::Model
  attr_accessor :quote_number, :customer_name, :manager_name, :company_name, :quote_status,
                :show_all, :sort_field, :direction, :per_page, :tag_ids, :defaults 

  def initialize(attributes = {})
    set_defaults
    @quote_number = attributes[:quote_number]
    @customer_name = attributes[:customer_name]
    @manager_name = attributes[:manager_name]
    @company_name = attributes[:company_name]
    @quote_status = attributes[:quote_status]
    @show_all = attributes[:show_all]
    @tag_ids = filtered_ids(attributes[:tag_ids])
    @sort_field = attributes[:sort_field] || defaults[:sort_field]
    @direction = attributes[:direction] || defaults[:direction]
    @per_page = attributes[:per_page] || defaults[:per_page]
  end

  def set_defaults
    @defaults = {}
    @defaults[:sort_field] = 'Quote date'
    @defaults[:direction] = 'Descending'
    @defaults[:per_page] = '10'
  end

  def filtered_ids(tag_ids)
    return unless tag_ids
    tag_ids.reject { |id| id.blank? }
  end

end