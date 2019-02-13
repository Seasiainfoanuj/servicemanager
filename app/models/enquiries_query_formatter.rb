module EnquiriesQueryFormatter

  def get_search_details
    if params[:page].present?
      if session[:search].present?
        session[:search]
      else
        params.delete :page
        EnquirySearch.new
      end
    else
      session.delete(:search)
      if params['enquiry_search'].present?
        EnquirySearch.new(search_params)
      else
        EnquirySearch.new
      end
    end
  end  

  def ordering
    direction = @search.direction == 'Ascending' ? 'ASC' : 'DESC'
    case @search.sort_field
    when "Enquiry Ref"
      "enquiries.uid #{direction}"
    when "Enquirer first name"
      "enquirer_first_name #{direction}, enquirer_last_name #{direction}"
    when "Enquirer last name"
      "enquirer_last_name #{direction}, enquirer_first_name #{direction}"
    when "Enquirer email"
      "enquirer_email #{direction}"
    when "Company name"
      "companies.name #{direction}, enquirer_first_name #{direction}, enquirer_last_name #{direction}"
    when "Enquiry status"
      "status #{direction}, enquiry_sort_date DESC"
    when "Enquiry score"
      "status #{direction}, enquiry_sort_date DESC"
    when "Enquiry type"
      "enquiry_type_name #{direction}, enquiry_sort_date DESC"
    when "Enquiry date"
      "enquiry_sort_date #{direction}"
    else
      "enquiries.enquiry_id ASC"
    end
  end

  def query_conditions
    return filter_for_uid if @search.uid.present?

    conditions = []
    conditions << filter_for_enquiry_status if @search.enquiry_status.present?
    conditions << filter_for_enquiry_type if @search.enquiry_type.present?
    conditions << filter_for_enquirer_name if @search.enquirer_name.present?
    conditions << filter_for_manager_name if @search.manager_name.present?
    conditions << filter_for_company_name if @search.company_name.present?
    if @filtered_user
      conditions << "enquirers.id = #{@filtered_user.id}"
    elsif !current_user.admin?
      conditions << "enquirers.id = #{@current_user.id}"
    end  

    if !(@search.show_all == "1") 
      conditions << "enquiries.status != 'closed' AND enquiries.updated_at > (DATE(NOW()) - INTERVAL 6 MONTH)"
    end  

    if conditions.none?
      query_string = "(enquiries.uid > '')" 
    else
      query_string = " ("
      query_string += conditions.join(' AND ') 
      query_string += ") "
    end
    query_string
  end

  def get_enquiries
    sel_str =  "enquiries.id AS enquiry_id, enquiries.uid, enquiries.seen, enquiries.flagged," 
    sel_str += " enquiries.status, enquiries.user_id, enquiries.manager_id, enquiries.updated_at,"
    sel_str += " date_format(enquiries.created_at, '%d/%m/%Y') AS enquiry_date,"
    sel_str += " date_format(enquiries.created_at, '%Y%m%d') AS enquiry_sort_date,"
    sel_str += " enquiry_types.name AS enquiry_type_name, enquiry_types.id AS enquiry_type_id,"
    sel_str += " enquirers.first_name AS enquirer_first_name, enquirers.last_name AS enquirer_last_name, enquirers.email AS enquirer_email,"
    sel_str += " CONCAT(managers.first_name, ' ', managers.last_name) AS manager_name,"
    sel_str += " enquiries.score AS enquiry_score,"
    sel_str += " companies.name AS enquirer_company_name, companies.id AS enquirer_company_id"

    enquiries = Enquiry.select(sel_str)
                  .joins("LEFT JOIN users AS enquirers on enquiries.user_id = enquirers.id")
                  .joins("LEFT JOIN users AS managers on enquiries.manager_id = managers.id")
                  .joins("LEFT JOIN companies on enquirers.representing_company_id = companies.id")
                  .joins("LEFT JOIN enquiry_types on enquiry_types.id = enquiries.enquiry_type_id")
                  .where(query_conditions)
  end

  def get_enquiries_dealers
    sel_str =  "enquiries.id AS enquiry_id, enquiries.uid, enquiries.seen, enquiries.flagged," 
    sel_str += " enquiries.status, enquiries.user_id, enquiries.manager_id, enquiries.updated_at,"
    sel_str += " date_format(enquiries.created_at, '%d/%m/%Y') AS enquiry_date,"
    sel_str += " date_format(enquiries.created_at, '%Y%m%d') AS enquiry_sort_date,"
    sel_str += " enquiry_types.name AS enquiry_type_name, enquiry_types.id AS enquiry_type_id,"
    sel_str += " enquirers.first_name AS enquirer_first_name, enquirers.last_name AS enquirer_last_name, enquirers.email AS enquirer_email,"
    sel_str += " CONCAT(managers.first_name, ' ', managers.last_name) AS manager_name,"
    sel_str += " enquiries.score AS enquiry_score,"
    sel_str += " companies.name AS enquirer_company_name, companies.id AS enquirer_company_id"

    enquiries = Enquiry.where('user_id = :current_user OR manager_id = :current_user', current_user: current_user.id).select(sel_str)
                  .joins("LEFT JOIN users AS enquirers on enquiries.user_id = enquirers.id")
                  .joins("LEFT JOIN users AS managers on enquiries.manager_id = managers.id")
                  .joins("LEFT JOIN companies on enquirers.representing_company_id = companies.id")
                  .joins("LEFT JOIN enquiry_types on enquiry_types.id = enquiries.enquiry_type_id")
                  .where(query_conditions)
  end


  def filter_for_uid
    "enquiries.uid = '#{@search.uid}'"
  end

  def filter_for_enquirer_name
    "(CONCAT(enquirers.first_name, ' ', enquirers.last_name, ' ', enquirers.email) LIKE '%#{@search.enquirer_name}%')"
  end

  def filter_for_manager_name
    "(CONCAT(managers.first_name, ' ', managers.last_name) LIKE '%#{@search.manager_name}%')"
  end
  def manager_name
    "(CONCAT(managers.first_name, ' ', managers.last_name) )"
  end
  def filter_for_company_name
    "companies.name LIKE '%#{@search.company_name}%'"
  end

  def filter_for_enquiry_status
    "enquiries.status = '#{@search.enquiry_status.downcase}'"
  end

  def filter_for_enquiry_type
    "enquiry_types.id = #{@search.enquiry_type.to_i}"
  end

  def filter_for_enquiry_type
    "enquiry_score = #{@search.enquiry_score}"
  end

end