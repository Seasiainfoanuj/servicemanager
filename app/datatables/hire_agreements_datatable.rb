class HireAgreementsDatatable
  delegate :params, :h, :link_to, :can?, :content_tag, :tag, :hire_status_label, :number_to_currency, :truncate, to: :@view

  def initialize(view, current_user, mode = nil)
    @view = view
    @current_user = current_user
    @mode = mode
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]

    params.each do |key,value|
      Rails.logger.warn "Param #{key}: #{value}"
    end
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_entries.to_i,
      recordsFiltered: hire_agreements.total_entries.to_i,
      aaData: data
    }
  end

private

  def data
    hire_agreements.map do |hire_agreement|
      [
        uid(hire_agreement),
        vehicle(hire_agreement),
        status(hire_agreement),
        customer(hire_agreement),
        pickup_date(hire_agreement),
        return_date(hire_agreement),
        action_links(hire_agreement)
      ]
    end
  end

  def action_links(hire_agreement)
    view_link(hire_agreement) + edit_link(hire_agreement) + destroy_link(hire_agreement)
  end

  def view_link(hire_agreement)
    if @vehicle
      link_to content_tag(:i, nil, class: 'icon-search'), {:action => 'show', :id => hire_agreement.uid, :vehicle_id => @vehicle.id}, {:title => 'View', :class => 'btn action-link', :rel =>'tooltip'}
    else
      link_to content_tag(:i, nil, class: 'icon-search'), {:action => 'show', :id => hire_agreement.uid}, {:title => 'View', :class => 'btn action-link', :rel =>'tooltip'}
    end
  end

  def edit_link(hire_agreement)
    if can? :update, HireAgreement
      if @vehicle
        link_to content_tag(:i, nil, class: 'icon-edit') , {:action => 'edit', :id => hire_agreement.uid, :vehicle_id => @vehicle.id}, {:title => 'Edit', :class => 'btn', 'rel' => 'tooltip'}
      else
        link_to content_tag(:i, nil, class: 'icon-edit') , {:action => 'edit', :id => hire_agreement.uid}, {:title => 'Edit', :class => 'btn', 'rel' => 'tooltip'}
      end
    end
  end

  def destroy_link(hire_agreement)
    if can? :destroy, HireAgreement
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), hire_agreement, method: :delete, :id => "hire_agreement-#{hire_agreement.id}-del-btn", :class => 'btn action-link hire_agreement-#{hire_agreement.id}-del-btn', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete Hire Agreement ##{hire_agreement.uid}. You cannot reverse this action. Are you sure you want to proceed?"}, :style => 'margin-left: 4px;'
    end
  end

  def uid(hire_agreement)
    link_to content_tag(:span, hire_agreement.uid, class: "label label-grey"), hire_agreement
  end

  def vehicle(hire_agreement)
    return unless hire_agreement.vehicle_id.present?
    result = []

    name = "#{hire_agreement.model_year} #{hire_agreement.make_name} #{hire_agreement.model_name}" if hire_agreement.model_year.present?
    if can? :read, Vehicle
      result << link_to(name, { controller: "vehicles", action: "show", id: hire_agreement.vehicle_id }) if hire_agreement.model_year.present?
    else
      result << name if hire_agreement.model_year.present?
    end
    result << tag("br")
    result << content_tag(:span, hire_agreement.vehicle_number, class: 'label label-satblue') if hire_agreement.vehicle_number.present?
    result << content_tag(:span, hire_agreement.call_sign, class: 'label label-green') if hire_agreement.call_sign.present?
    result << content_tag(:span, hire_agreement.rego_number, class: 'label label-grey') if hire_agreement.rego_number.present?
    result << content_tag(:span, hire_agreement.vin_number.to_s, class: 'label') if hire_agreement.vin_number.present?
    result.join('')
  end

  def status(hire_agreement)
    hire_status_label(hire_agreement.status)
  end

  def customer(hire_agreement)
    if can? :read, User
      link_to hire_agreement.customer.company_name_short, {:controller => 'users', :action => 'show', :id => hire_agreement.customer_id} if hire_agreement.customer
    else
      hire_agreement.customer.company_name_short if hire_agreement.customer
    end
  end

  def pickup_date(hire_agreement)
    if hire_agreement.pickup_date_formatted.present?
      "#{hire_agreement.pickup_date_formatted} - <b>#{hire_agreement.pickup_time_formatted}</b>"
    end
  end

  def return_date(hire_agreement)
    if hire_agreement.return_date_formatted.present?
      "#{hire_agreement.return_date_formatted} - <b>#{hire_agreement.return_time_formatted}</b>"
    end
  end

  def hire_agreements
    @hire_agreements ||= fetch_hire_agreements
  end

  def fetch_hire_agreements
    hire_agreements = init_hire_agreements

    if params[:search] && params[:search][:value].present?
      rows = %w[ uid
                  hire_agreements.status
                  vehicle_makes.name
                  vehicle_models.name
                  vehicles.model_year
                  vehicle_number
                  vin_number
                  engine_number
                  location
                  rego_number
                  call_sign
                  class_type
                  customers.first_name
                  customers.last_name
                  customers.email
                  customers.company
                ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      hire_agreements = hire_agreements.where(search, search_params).order("#{sort_column} #{sort_direction}")
    end

    hire_agreements.page(page).per_page(per_page)
  end

  def init_hire_agreements
    @pre_hire_agreements ||= pre_hire_agreements
  end

  def pre_hire_agreements
    sel_str = "hire_agreements.id, hire_agreements.uid, hire_agreements.status, hire_agreements.customer_id, vehicles.location,
                        vehicles.id, customers.id, vehicles.vehicle_number, vehicles.call_sign, vehicles.vin_number,
                        vehicle_id, CONCAT(customers.first_name, ' ', customers.last_name) AS customer_name, vehicles.class_type,
                        vehicle_makes.name AS make_name, vehicle_models.name AS model_name, vehicles.model_year,
                        customers.first_name, customers.last_name, customers.company, customers.email,
                        vehicles.rego_number, vehicles.stock_number, vehicles.kit_number,
                        date_format(hire_agreements.pickup_time, '%d/%m/%Y') AS pickup_date_formatted,
                        date_format(hire_agreements.pickup_time, '%l:%i %p') AS pickup_time_formatted,
                        date_format(hire_agreements.return_time, '%d/%m/%Y') AS return_date_formatted,
                        date_format(hire_agreements.return_time, '%l:%i %p') AS return_time_formatted,
                        date_format(hire_agreements.pickup_time, '%Y %m %d %k %i') AS pickup_date_time_sort,
                        date_format(hire_agreements.return_time, '%Y %m %d %k %i') AS return_date_time_sort"

    if @current_user.has_role? :admin
      hire_agreements = HireAgreement.select(sel_str)
                                      .joins("LEFT JOIN vehicles on vehicles.id = hire_agreements.vehicle_id")
                                      .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                                      .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                                      .joins("LEFT JOIN users AS customers on customers.id = hire_agreements.customer_id")
                                      .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? [:service_provider, :customer]
            hire_agreements = HireAgreement.select(sel_str)
                                      .joins("LEFT JOIN vehicles on vehicles.id = hire_agreements.vehicle_id")
                                      .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                                      .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                                      .joins("LEFT JOIN users AS customers on customers.id = hire_agreements.customer_id")
                                      .where("customer_id = ?", @current_user.id)
                                      .order("#{sort_column} #{sort_direction}")

    end

    hire_agreements = hire_agreements.where('vehicles.id = ?', @vehicle.id) if @vehicle
    hire_agreements = hire_agreements.where("manager_id = :user or customer_id = :user", user: @filtered_user.id) if @filtered_user

    if params[:showAll] && params[:showAll] == 'false'
      hire_agreements.where("hire_agreements.status != 'returned' && hire_agreements.status != 'cancelled'")
    else
      hire_agreements
    end
  end

  def new_total_entries
    sel_str = "hire_agreements.id"

    if @current_user.has_role? :admin
      hire_agreements = HireAgreement.select(sel_str)
                                      .joins("LEFT JOIN vehicles on vehicles.id = hire_agreements.vehicle_id")
                                      .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                                      .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                                      .joins("LEFT JOIN users AS customers on customers.id = hire_agreements.customer_id")
                                      .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? [:service_provider, :customer]
            hire_agreements = HireAgreement.select(sel_str)
                                      .joins("LEFT JOIN vehicles on vehicles.id = hire_agreements.vehicle_id")
                                      .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                                      .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                                      .joins("LEFT JOIN users AS customers on customers.id = hire_agreements.customer_id")
                                      .where("customer_id = ?", @current_user.id)
                                      .order("#{sort_column} #{sort_direction}")

    end

    hire_agreements = hire_agreements.where('vehicles.id = ?', @vehicle.id) if @vehicle
    hire_agreements = hire_agreements.where("manager_id = :user or customer_id = :user", user: @filtered_user.id) if @filtered_user

    if params[:showAll] && params[:showAll] == 'false'
     hire_agreements = hire_agreements.where("hire_agreements.status != 'returned' && hire_agreements.status != 'cancelled'")
     hire_agreements.count
    else
      hire_agreements
      hire_agreements.count
    end
  end

  def total_records
    init_hire_agreements.count
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[uid vehicles.model_year hire_agreements.status customer_name pickup_date_time_sort return_date_time_sort]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
