module HireQuotesQueryFormatter

  def get_search_details
    if params[:page].present?
      if session[:hire_quote_search].present?
        session[:hire_quote_search]
      else
        params.delete :page
        HireQuoteSearch.new
      end
    else
      session.delete(:hire_quote_search)
      if params['hire_quote_search'].present?
        HireQuoteSearch.new(search_params)
      else
        HireQuoteSearch.new
      end
    end
  end  

  def ordering
    direction = @search.direction == 'Ascending' ? 'ASC' : 'DESC'
    case @search.sort_field
    when "Hire Quote Ref"
      "hire_quotes.reference #{direction}"
    when "Customer first name"
      "customer_first_name #{direction}, customer_last_name #{direction}"
    when "Customer last name"
      "customer_last_name #{direction}, customer_first_name #{direction}"
    when "Customer email"
      "customer_email #{direction}"
    when "Company name"
      "company_name #{direction}"
    when "Status"
      "status #{direction}, hire_status_date DESC"
    else
      "quote_updated_at DESC"
    end  
  end  

  def query_conditions
    return filter_for_reference if @search.reference.present?
    conditions = []
    conditions << filter_for_status if @search.status.present?
    conditions << filter_for_customer_name if @search.customer_name.present?
    conditions << filter_for_manager_name if @search.manager_name.present?
    conditions << filter_for_company_name if @search.company_name.present?
    conditions << filter_by_tag_name if @search.tags.present? and has_tags?(@search.tags)

    if @filtered_user
      conditions << "psn_customers.id = #{@filtered_user.id}"
    elsif !current_user.admin?
      conditions << "hire_quotes.authorised_contact_id = #{current_user.id}"
      conditions << "hire_quotes.status <> 'draft'"
    end  

    if !(@search.show_all == "1") 
      conditions << "hire_quotes.updated_at > (DATE(NOW()) - INTERVAL 6 MONTH)"
    end  

    if conditions.none?
      query_string = "(hire_quotes.reference > '')" 
    else
      query_string = " (" + conditions.join(' AND ') + ") "
    end
    query_string
  end

  def has_tags?(tag_list)
    tag_list.each do |tag|
      return true if tag.present?
    end
    false
  end

  def get_hire_quotes
    sel_str =  "hire_quotes.id AS hire_quote_id, hire_quotes.reference, hire_quotes.authorised_contact_id,"
    sel_str += " hire_quotes.updated_at AS quote_updated_at, hire_quotes.customer_id,"
    sel_str += " hire_quotes.manager_id, psn_customers.id AS user_id, hire_quotes.version,"
    sel_str += " cpy_customers.id AS company_id, cpy_customers.name AS company_name,"
    sel_str += " hire_quotes.status_date, hire_quotes.status, hire_quotes.tags,"
    sel_str += " date_format(hire_quotes.status_date, '%d/%m/%Y') AS hire_status_date,"
    sel_str += " psn_customers.first_name AS customer_first_name, psn_customers.last_name AS customer_last_name,"
    sel_str += " psn_customers.email AS customer_email, customer_clients.client_type AS client_type,"
    sel_str += " managers.first_name AS manager_first_name, managers.last_name AS manager_last_name"

    hire_quotes = HireQuote.select(sel_str)
                    .joins("LEFT JOIN clients AS customer_clients on hire_quotes.customer_id = customer_clients.id")
                    .joins("LEFT JOIN clients AS manager_clients on hire_quotes.manager_id = manager_clients.id")
                    .joins("LEFT JOIN users AS psn_customers on customer_clients.user_id = psn_customers.id")
                    .joins("LEFT JOIN users AS managers on manager_clients.user_id = managers.id")
                    .joins("LEFT JOIN companies AS cpy_customers on customer_clients.company_id = cpy_customers.id")
                    .where(query_conditions)
  end

  def filter_for_reference
    "hire_quotes.reference = '#{@search.reference}'"
  end

  def filter_for_customer_name
    "(CONCAT(psn_customers.first_name, ' ', psn_customers.last_name, ' ', psn_customers.email) LIKE '%#{@search.customer_name}%')"
  end

  def filter_for_manager_name
    "(CONCAT(managers.first_name, ' ', managers.last_name) LIKE '%#{@search.manager_name}%')"
  end

  def filter_for_company_name
    "cpy_customers.name LIKE '%#{@search.company_name}%'"
  end

  def filter_for_status
    "status = '#{@search.status.downcase}'"
  end

  def filter_by_tag_name
    tag_list = @search.tags.reject { |tag| tag.blank? }
    formatted_list = tag_list.map { |tag| "tags LIKE '%#{tag}%'" }.join(" OR ")
  end

end