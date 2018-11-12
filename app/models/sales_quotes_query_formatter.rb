module SalesQuotesQueryFormatter

  def get_search_details
    if params[:page].present?
      if session[:sales_quotes_search].present?
        session[:sales_quotes_search]
      else
        params.delete :page
        QuoteSearch.new
      end
    else
      session.delete(:sales_quotes_search)
      if params['quote_search'].present?
        QuoteSearch.new(search_params)
      else
        QuoteSearch.new
      end
    end
  end  

  def ordering
    direction = @search.direction == 'Ascending' ? 'ASC' : 'DESC'
    case @search.sort_field
    when "Quote number"
      "quotes.number #{direction}"
    when "Customer first name"
      "customer_first_name #{direction}, customer_last_name #{direction}"
    when "Customer last name"
      "customer_last_name #{direction}, customer_first_name #{direction}"
    when "Customer email"
      "customer_email #{direction}"
    when "Company name"
      "companies.name #{direction}, customer_first_name #{direction}, customer_last_name #{direction}"
    when "Quote status"
      "status #{direction}, quote_sort_date DESC"
    when "Quote date"
      "quote_sort_date #{direction}"
    when "Quote total amount"
      "total_cents #{direction}"
    else
      "quote_id ASC"
    end
  end

  def query_conditions
    return filter_by_quote_number if @search.quote_number.present?

    conditions = []
    conditions << filter_by_quote_status if @search.quote_status.present?
    conditions << filter_by_customer_name if @search.customer_name.present?
    conditions << filter_by_manager_name if @search.manager_name.present?
    conditions << filter_by_company_name if @search.company_name.present?
    conditions << filter_by_tag_name if @search.tag_ids.present?

    if @filtered_user
      conditions << "customers.id = #{@filtered_user.id}"
    elsif !current_user.admin?
      conditions << "customers.id = #{current_user.id}"
      conditions << "quotes.status <> 'draft'"
    end  

    if !(@search.show_all == "1") 
      conditions << "quotes.status != 'cancelled' AND quotes.updated_at > (DATE(NOW()) - INTERVAL 6 MONTH)"
    end  
    
    if conditions.none?
      query_string = "(quotes.number > '0')" 
    else
      query_string = " ("
      query_string += conditions.join(' AND ') 
      query_string += ") "
    end
    query_string
  end

  def get_quotes
    sel_str =  "quotes.id AS quote_id, quotes.number, quotes.total_cents," 
    sel_str += " quotes.updated_at, quotes.status, quotes.manager_id, quotes.customer_id,"
    sel_str += " date_format(quotes.date, '%d/%m/%Y') AS quote_date,"
    sel_str += " date_format(quotes.date, '%Y%m%d') AS quote_sort_date,"
    sel_str += " customers.first_name AS customer_first_name, customers.last_name AS customer_last_name, customers.email AS customer_email,"
    sel_str += " managers.first_name AS manager_first_name, managers.last_name AS manager_last_name,"
    sel_str += " companies.name AS customer_company_name, companies.id AS customer_company_id,"
    sel_str += " tags.id, taggings.tag_id, GROUP_CONCAT(tags.name SEPARATOR ', ') AS tag_names"

    quotes = Quote.select(sel_str)
              .joins("LEFT JOIN users AS customers on quotes.customer_id = customers.id")
              .joins("LEFT JOIN users AS managers on quotes.manager_id = managers.id")
              .joins("LEFT JOIN companies on customers.representing_company_id = companies.id")
              .joins("LEFT JOIN taggings ON taggings.taggable_id = quotes.id AND taggings.taggable_type = 'Quote'")
              .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
              .where(query_conditions)
              .group('quotes.id')
  end
  
  def get_quotes_dealer
    sel_str =  "quotes.id AS quote_id, quotes.number, quotes.total_cents," 
    sel_str += " quotes.updated_at, quotes.status, quotes.manager_id, quotes.customer_id,"
    sel_str += " date_format(quotes.date, '%d/%m/%Y') AS quote_date,"
    sel_str += " date_format(quotes.date, '%Y%m%d') AS quote_sort_date,"
    sel_str += " customers.first_name AS customer_first_name, customers.last_name AS customer_last_name, customers.email AS customer_email,"
    sel_str += " managers.first_name AS manager_first_name, managers.last_name AS manager_last_name,"
    sel_str += " companies.name AS customer_company_name, companies.id AS customer_company_id,"
    sel_str += " tags.id, taggings.tag_id, GROUP_CONCAT(tags.name SEPARATOR ', ') AS tag_names"

    quotes = Quote.where(:manager_id => current_user.id).select(sel_str)
              .joins("LEFT JOIN users AS customers on quotes.customer_id = customers.id")
              .joins("LEFT JOIN users AS managers on quotes.manager_id = managers.id")
              .joins("LEFT JOIN companies on customers.representing_company_id = companies.id")
              .joins("LEFT JOIN taggings ON taggings.taggable_id = quotes.id AND taggings.taggable_type = 'Quote'")
              .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
              .where(query_conditions)
              .group('quotes.id')
  end

  def get_quotes_users(user_id)
    sel_str =  "quotes.id AS quote_id, quotes.number, quotes.total_cents," 
    sel_str += " quotes.updated_at, quotes.status, quotes.manager_id, quotes.customer_id,"
    sel_str += " date_format(quotes.date, '%d/%m/%Y') AS quote_date,"
    sel_str += " date_format(quotes.date, '%Y%m%d') AS quote_sort_date,"
    sel_str += " customers.first_name AS customer_first_name, customers.last_name AS customer_last_name, customers.email AS customer_email,"
    sel_str += " managers.first_name AS manager_first_name, managers.last_name AS manager_last_name,"
    sel_str += " companies.name AS customer_company_name, companies.id AS customer_company_id,"
    sel_str += " tags.id, taggings.tag_id, GROUP_CONCAT(tags.name SEPARATOR ', ') AS tag_names"

    quotes = Quote.where(:customer_id => user_id).select(sel_str)
              .joins("LEFT JOIN users AS customers on quotes.customer_id = customers.id")
              .joins("LEFT JOIN users AS managers on quotes.manager_id = managers.id")
              .joins("LEFT JOIN companies on customers.representing_company_id = companies.id")
              .joins("LEFT JOIN taggings ON taggings.taggable_id = quotes.id AND taggings.taggable_type = 'Quote'")
              .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
              .where(query_conditions)
              .group('quotes.id')
  end


  def filter_by_quote_number
    "quotes.number = '#{@search.quote_number}'"
  end

  def filter_by_quote_status
    "quotes.status = '#{@search.quote_status.downcase}'"
  end

  def filter_by_customer_name
    "(CONCAT(customers.first_name, ' ', customers.last_name, ' ', customers.email) LIKE '%#{@search.customer_name}%')"
  end

  def filter_by_manager_name
    "(CONCAT(managers.first_name, ' ', managers.last_name) LIKE '%#{@search.manager_name}%')"
  end

  def filter_by_company_name
    "companies.name LIKE '%#{@search.company_name}%'"
  end

  def filter_by_tag_name
    return unless @search.tag_ids.present?
    all_quote_ids = []
    @search.tag_ids.each do |tag_id|
      tag = ActsAsTaggableOn::Tag.find_by(id: tag_id)
      quote_ids = tag.taggings.map(&:taggable_id)
      next if quote_ids.none?
      all_quote_ids = all_quote_ids | quote_ids
    end
    return if all_quote_ids.none?
    quotes_set = all_quote_ids.inspect.gsub("[","(").gsub("]", ")")
    "quotes.id IN #{quotes_set}"
  end

end