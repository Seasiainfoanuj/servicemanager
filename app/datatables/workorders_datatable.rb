class WorkordersDatatable
  delegate Fixnum, :params, :h, :can?, :link_to, :number_to_currency, :content_tag, :workorder_status_label, :job_sp_invoiced_status, :tag, to: :@view

  def initialize(view, current_user)
   
    @view = view
    @current_user = current_user
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_entries,
      recordsFiltered: workorders.total_entries,
      data: data
    }
  end

private

  def data
    if @current_user.has_role? :admin

      workorders.map do |workorder|
        [
          workorder_uid(workorder),
          workorder_type(workorder),
          vehicle(workorder),
          workorder_status_label(workorder.status),
          recurring(workorder),
          service_provider(workorder),
          sp_invoice(workorder),
          customer(workorder),
          schedule(workorder),
          etc(workorder),
          action_links(workorder)
        ]
      end
    else
      workorders.map do |workorder|
        [
          workorder_uid(workorder),
          workorder_type(workorder),
          vehicle(workorder),
          workorder_status_label(workorder.status),
          recurring(workorder),
          service_provider(workorder),
          customer(workorder),
          schedule(workorder),
          etc(workorder),
          action_links(workorder)
        ]
      end
    end
  end

  def workorder_uid(workorder)
    link_to content_tag(:span, workorder.uid, class: 'label label-grey'), workorder
  end

  def workorder_type(workorder)
    content_tag(:span, workorder.type.name, class: 'label', style: "background-color: #{workorder.type.label_color}")
  end

  def vehicle(workorder)
    # workorder.inspect
      return unless workorder.vehicle_id.present?
      result = []

      name = "#{workorder.model_year} #{workorder.make_name} #{workorder.model_name}" if workorder.model_year.present?
      if can? :read, Vehicle
        result << link_to(name, { controller: "vehicles", action: "show", id: workorder.vehicle_id }) if workorder.vehicle_id.present?
      else
        result << name if workorder.vehicle_id.present?
      end
      result << tag("br")
      result << content_tag(:span, workorder.vehicle_number, class: 'label label-satblue') if workorder.vehicle_number.present?
      result << content_tag(:span, workorder.call_sign, class: 'label label-green') if workorder.call_sign.present?
      result << content_tag(:span, workorder.rego_number, class: 'label label-grey') if workorder.rego_number.present?
      result << content_tag(:span, workorder.vin_number.to_s, class: 'label') if workorder.vin_number.present?
      result.join('')
  end

  def recurring(workorder)
    "#{workorder.recurring_period} Days" if workorder.is_recurring
  end

  def service_provider(workorder)
    unless @current_user.has_role? :service_provider
      if can? :read, User
        return link_to(workorder.service_provider.company_name_short, workorder.service_provider) if workorder.service_provider
      else
        return workorder.service_provider.company_name_short if workorder.service_provider
      end
    end
  end

  def sp_invoice(workorder)
    job_sp_invoiced_status(workorder)
  end

  def customer(workorder)
    unless @current_user.has_role? :customer
      if can? :read, User
        link_to(workorder.customer.company_name_short, workorder.customer) if workorder.customer
      else
        workorder.customer.company_name_short if workorder.customer
      end
    end
  end

  def schedule(workorder)
    "#{content_tag(:span, workorder.sched_time.strftime("%Y-%m-%d %H-%M"), class: 'hidden')}
        #{workorder.sched_date_field} - #{workorder.sched_time_field}"
  end

  def etc(workorder)
    "#{content_tag(:span, workorder.etc.strftime("%Y-%m-%d %H-%M"), class: 'hidden')}
        #{workorder.etc_date_field} - #{workorder.etc_time_field}"
  end

  def action_links(workorder)
    view_link(workorder) + edit_link(workorder) + destroy_link(workorder)
  end

  def view_link(workorder)
    link_to content_tag(:i, nil, class: 'icon-search'), workorder, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_link(workorder)
    if can? :update, Workorder
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "workorders", action: "edit", id: workorder.id}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_link(workorder)
    if can? :destroy, Workorder
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), workorder, method: :delete, :id => "workorder-#{workorder.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete workorder number #{workorder.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def total_records
    init_workorders.count
  end

  def workorders
    @workorders ||= fetch_workorders
  end

  def fetch_workorders
    workorders = init_workorders

    if params[:search] && params[:search][:value].present?
       rows = %w[ uid
                    workorder_types.name
                    vehicle_makes.name
                    vehicle_models.name
                    vehicles.model_year
                    vehicles.vehicle_number
                    vehicles.vin_number
                    vehicles.engine_number
                    vehicles.location
                    vehicles.rego_number
                    vehicles.call_sign
                    vehicles.class_type
                    service_providers.first_name
                    service_providers.last_name
                    service_providers.company
                    service_providers.email
                    customers.first_name
                    customers.last_name
                    customers.company
                    customers.email
                    sp_invoices.status
                    workorders.status
                ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      workorders = workorders.where(search, search_params).order("#{sort_column} #{sort_direction}")
    end

    workorders.page(page).per_page(per_page)
  end

  def init_workorders
    @pre_workorders ||= pre_workorders
  end

  def pre_workorders
    sel_str = "workorders.id, workorders.uid, workorder_types.name AS workorder_type, workorders.status, workorders.recurring_period,
               CONCAT(vehicles.model_year, ' ', vehicle_models.name, ' ', vehicle_makes.name) AS vehicle_name,
               CONCAT(service_providers.company, service_providers.first_name, ' ', service_providers.last_name) AS service_provider_name,
               CONCAT(customers.company, customers.first_name, ' ', customers.last_name) AS customer_name,
               workorders.sched_time, workorders.etc, workorders.workorder_type_id, workorders.vehicle_id, workorders.is_recurring,
               workorders.service_provider_id, workorders.customer_id, sp_invoices.status AS sp_invoiced_status,
               vehicle_makes.name AS make_name, vehicle_models.name AS model_name, vehicles.model_year, vehicles.call_sign,
               vehicles.rego_number, vehicles.stock_number, vehicles.kit_number, vehicles.vehicle_number, vehicles.vin_number"

    if @current_user.has_role? :admin
     workorders = Workorder.select(sel_str)
                           .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                           .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                           .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                           .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :service_provider
     workorders = Workorder.select(sel_str)
                           .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                           .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                           .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                           .where("workorders.service_provider_id = ?", [@current_user.id])
                           .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :supplier
      workorders = Workorder.select(sel_str)
                            .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                            .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                            .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                            .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                            .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                            .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                            .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                            .where("workorders.service_provider_id = ?", [@current_user.id])
                            .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :customer
     workorders = Workorder.select(sel_str)
                           .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                           .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                           .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                           .joins("LEFT JOIN job_subscribers on workorders.id = job_subscribers.job_id")
                           .where("job_subscribers.job_type = 'Workorder' && job_subscribers.user_id = :current_user_id OR workorders.customer_id = :current_user_id", current_user_id: @current_user.id)
                           .order("#{sort_column} #{sort_direction}")
    end

    workorders = @vehicle ? workorders.where('vehicles.id = ?', @vehicle.id) : workorders
    workorders = @filtered_user ? workorders.where('manager_id = :user or service_provider_id = :user or customer_id = :user',
                                                    user: @filtered_user.id) : workorders

    if params[:showAll] && params[:showAll] == 'false'
      workorders.where("workorders.status != 'complete' && workorders.status != 'cancelled'")
    else
      workorders
    end
  end


   def new_total_entries
    sel_str = "workorders.id"

    if @current_user.has_role? :admin
     workorders = Workorder.select(sel_str)
                           .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                           .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                           .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                           .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :service_provider
     workorders = Workorder.select(sel_str)
                           .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                           .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                           .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                           .where("workorders.service_provider_id = ?", [@current_user.id])
                           .order("#{sort_column} #{sort_direction}")
    
    elsif @current_user.has_role? :supplier
      workorders = Workorder.select(sel_str)
                            .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                            .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                            .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                            .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                            .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                            .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                            .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                            .where("workorders.service_provider_id = ?", [@current_user.id])
                            .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :customer
     workorders = Workorder.select(sel_str)
                           .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                           .joins("LEFT JOIN vehicles on workorders.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on workorders.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN users AS customers on workorders.customer_id = customers.id")
                           .joins("LEFT JOIN sp_invoices on workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                           .joins("LEFT JOIN job_subscribers on workorders.id = job_subscribers.job_id")
                           .where("job_subscribers.job_type = 'Workorder' && job_subscribers.user_id = :current_user_id OR workorders.customer_id = :current_user_id", current_user_id: @current_user.id)
                           .order("#{sort_column} #{sort_direction}")
    
    end

    workorders = @vehicle ? workorders.where('vehicles.id = ?', @vehicle.id) : workorders
    workorders = @filtered_user ? workorders.where('manager_id = :user or service_provider_id = :user or customer_id = :user',
                                                    user: @filtered_user.id) : workorders

    if params[:showAll] && params[:showAll] == 'false'
      workorders = workorders.where("workorders.status != 'complete' && workorders.status != 'cancelled'")
      workorders.count
    else
      workorders.count
    end
    
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[uid workorder_types.name vehicles.model_year workorders.status recurring_period service_provider_name sp_invoiced_status customer_name sched_time etc]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
