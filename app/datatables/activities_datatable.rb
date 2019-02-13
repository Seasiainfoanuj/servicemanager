class ActivitiesDatatable
  delegate :params, :h, :link_to, :can?, :content_tag, :render, :time_ago_in_words, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_entries,
      recordsFiltered: activities.total_entries,
      data: data
    }
  end

  def data
    if @current_user.has_role? :dealer
      activities.where( :owner_id =>  @current_user.id).map do |activity|
        [
          content(activity)
        ]
      end
    else 
      activities.map do |activity|
        [
          content(activity)
        ]
      end 
    end
  end

  def content(activity)
    key = activity.key.split('.')
    time = "#{time_ago_in_words(activity.created_at)} ago (#{activity.created_at.strftime("%e %b %Y, %l:%M %p")})"
    p1 = render "public_activity/#{key[0]}/#{key[1]}.html.erb", activity: activity
    p1 + content_tag(:span, time, class: 'activity-time')
  end

  def total_entries
    if @current_user.has_role? :dealer
      init_activities.where( :owner_id =>  @current_user.id).count
    else   
      init_activities.count
    end  
  end

  def activities
    @activities ||= fetch_activities
  end

  def fetch_activities
    activities = pre_activities
    
    if params[:search] && params[:search][:value].present?
      # company = owner.representing_company.present? ?  owner.representing_company.name : ""
      rows = %w[ trackable_type
                 activities.key
                 owner.first_name
                 owner.last_name
                 owner.company
                 owner.email
                 builds.number
                 build_specifications.id
                 build_orders.uid
                 enquiries.uid
                 hire_agreements.uid
                 master_quotes.name
                 notes.resource_type
                 notification_types.id
                 notifications.id
                 off_hire_jobs.uid
                 po_requests.uid
                 quotes.number
                 vehicle_contracts.uid
                 stock_requests.uid
                 vehicles.rego_number
                 workorders.uid
                 sp_invoices.invoice_number
               ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} LIKE :search#{index}" }.join(" OR ") + ")" }.join(" AND ")

      activities = activities.where(search, search_params).order("created_at #{sort_direction}")
    end
    activities.page(page).per_page(per_page)
  end

  def init_activities
    @pre_activities ||= pre_activities
  end

  def pre_activities
    activities = PublicActivity::Activity.order("created_at desc")
                                         .joins("LEFT JOIN users AS owner on activities.owner_id = owner.id")
                                         .joins("LEFT JOIN builds ON activities.trackable_id = builds.id AND activities.trackable_type = 'Build'")
                                         .joins("LEFT JOIN build_specifications ON activities.trackable_id = build_specifications.id AND activities.trackable_type = 'BuildSpecification'")
                                         .joins("LEFT JOIN build_orders ON activities.trackable_id = build_orders.id AND activities.trackable_type = 'BuildOrder'")
                                         .joins("LEFT JOIN enquiries ON activities.trackable_id = enquiries.id AND activities.trackable_type = 'Enquiry'")
                                         .joins("LEFT JOIN hire_agreements ON activities.trackable_id = hire_agreements.id AND activities.trackable_type = 'HireAgreement'")
                                         .joins("LEFT JOIN master_quotes ON activities.trackable_id = master_quotes.id AND activities.trackable_type = 'MasterQuote'")
                                         .joins("LEFT JOIN notes ON activities.trackable_id = notes.id AND activities.trackable_type = 'Note'")
                                         .joins("LEFT JOIN notifications ON activities.trackable_id = notifications.id AND activities.trackable_type = 'Notification'")
                                         .joins("LEFT JOIN notification_types ON activities.trackable_id = notification_types.id AND activities.trackable_type = 'NotificationType'")
                                         .joins("LEFT JOIN off_hire_jobs ON activities.trackable_id = off_hire_jobs.id AND activities.trackable_type = 'OffHireJob'")
                                         .joins("LEFT JOIN po_requests ON activities.trackable_id = po_requests.id AND activities.trackable_type = 'PoRequest'")
                                         .joins("LEFT JOIN quotes ON activities.trackable_id = quotes.id AND activities.trackable_type = 'Quote'")
                                         .joins("LEFT JOIN vehicle_contracts ON activities.trackable_id = vehicle_contracts.id AND activities.trackable_type = 'VehicleContract'")
                                         .joins("LEFT JOIN stock_requests ON activities.trackable_id = stock_requests.id AND activities.trackable_type = 'StockRequest'")
                                         .joins("LEFT JOIN vehicles ON activities.trackable_id = vehicles.id AND activities.trackable_type = 'Vehicle'")
                                         .joins("LEFT JOIN workorders ON activities.trackable_id = workorders.id AND activities.trackable_type = 'Workorder'")
                                         .joins("LEFT JOIN sp_invoices ON activities.trackable_id = sp_invoices.id AND activities.trackable_type = 'SpInvoice'")
    activities.order("created_at #{sort_direction}")
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[activities.created_at]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
