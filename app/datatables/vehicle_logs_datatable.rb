include VehicleLogsHelper
class VehicleLogsDatatable
  delegate Fixnum, :params, :h, :can?, :link_to, :vehicle_log_order_progress_class, :number_to_percentage, :content_tag, :tag, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_records,
      recordsFiltered: vehicle_logs.total_entries,
      data: data
    }
  end

private

  def data
    if @vehicle
      vehicle_logs.map do |vehicle_log|
        [
          log_flagged_icon(vehicle_log),
          uid(vehicle_log),
          vehicle_log.name,
          workorder(vehicle_log),
          service_provider(vehicle_log),
          vehicle_log.odometer_reading,
          vehicle_log.updated_at,
          action_links(vehicle_log)
        ]
      end
    else
      vehicle_logs.map do |vehicle_log|
        [
          log_flagged_icon(vehicle_log),
          uid(vehicle_log),
          vehicle(vehicle_log),
          vehicle_log.name,
          workorder(vehicle_log),
          service_provider(vehicle_log),
          vehicle_log.odometer_reading,
          vehicle_log.updated_at,
          action_links(vehicle_log)
        ]
      end
    end
  end

  def action_links(vehicle_log)
    view_link(vehicle_log) + edit_link(vehicle_log) + destroy_link(vehicle_log)
  end

  def view_link(vehicle_log)
    link_to content_tag(:i, nil, class: 'icon-search'), {controller: "vehicle_logs", action: "show", id: vehicle_log.id}, {:title => 'View', :class => 'btn action-link' }
  end

  def edit_link(vehicle_log)
    if can? :update, VehicleLog
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "vehicle_logs", action: "edit", id: vehicle_log.id, vehicle_id: vehicle_log.vehicle.id}, :title => 'Edit', :class => 'btn action-link'
    end
  end

  def destroy_link(vehicle_log)
    if can? :destroy, VehicleLog
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), {controller: "vehicle_logs", action: "edit", id: vehicle_log.id}, method: :delete, :id => "vehicle_log-#{vehicle_log.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete log entry #{vehicle_log.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def uid(vehicle_log)
    link_to content_tag(:span, vehicle_log.uid, class: 'label label-grey'), {:controller => 'vehicle_logs', :action => 'show', :id => vehicle_log.id }
  end

  def vehicle(vehicle_log)
    return unless vehicle_log.vehicle_id.present?
    result = []

    name = "#{vehicle_log.vehicle_year} #{vehicle_log.make_name} #{vehicle_log.model_name}"
    if can? :read, Vehicle
      result << link_to(name, { controller: "vehicles", action: "show", id: vehicle_log.vehicle_id })
    else
      result << name
    end
    result << tag("br")
    result << content_tag(:span, vehicle_log.vehicle_number, class: 'label label-satblue') if vehicle_log.vehicle_number.present?
    result << content_tag(:span, vehicle_log.call_sign, class: 'label label-green') if vehicle_log.call_sign.present?
    result << content_tag(:span, vehicle_log.rego_number, class: 'label label-grey') if vehicle_log.rego_number.present?
    result << content_tag(:span, vehicle_log.vin_number.to_s, class: 'label') if vehicle_log.vin_number.present?
    result.join('')
  end

  def workorder(vehicle_log)
    return unless vehicle_log.workorder_type && vehicle_log.workorder_uid
    content_tag(:span, vehicle_log.workorder_type, class: 'label label-satblue') +
        content_tag(:span, vehicle_log.workorder_uid, class: 'label label-lightgrey')
  end

  def service_provider(vehicle_log)
    vehicle_log.service_provider_name if vehicle_log.service_provider_name
  end

  def total_records
    init_vehicle_logs.count
  end

  def vehicle_logs
    @vehicle_logs ||= fetch_vehicle_logs
  end

  def fetch_vehicle_logs
    vehicle_logs = init_vehicle_logs

    if params[:search] && params[:search][:value].present?
      rows = %w[
                  vehicle_logs.uid
                  vehicle_logs.name
                  workorders.uid
                  rego_number
                  stock_number
                  kit_number
                  call_sign
                  vehicle_makes.name
                  vehicles.model_year
                  vehicle_models.name
                  users.first_name
                  users.last_name
                  users.company
                  users.email
                ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }

      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      vehicle_logs = vehicle_logs.where(search, search_params)
    end

    vehicle_logs.page(page).per_page(per_page).order("#{sort_column} #{sort_direction}")
  end

  def init_vehicle_logs
    @pre_vehicle_logs ||= pre_vehicle_logs
  end

  def pre_vehicle_logs
    sel_str = "vehicle_logs.id, vehicle_logs.vehicle_id, vehicle_logs.uid, vehicle_logs.flagged, vehicles.model_year,
               vehicle_logs.service_provider_id, vehicle_logs.name, CAST(vehicle_logs.odometer_reading AS signed) AS odometer_reading,
               date_format(vehicle_logs.updated_at, '%d/%m/%Y %I:%i %p') AS updated_at, vehicles.vehicle_number,
               vehicle_makes.name AS make_name, vehicle_models.name AS model_name, vehicles.model_year AS vehicle_year,
               vehicles.rego_number, vehicles.stock_number, vehicles.kit_number, vehicles.call_sign, vehicles.vin_number,
               workorders.uid AS workorder_uid, workorder_types.name AS workorder_type, users.id AS user_id,
               CONCAT(users.first_name, ' ', users.last_name, ' ', users.company) AS service_provider_name, users.email"

    if @current_user.has_role? :admin
        vehicle_logs = VehicleLog.select(sel_str)
                                .joins("LEFT JOIN vehicles on vehicles.id = vehicle_logs.vehicle_id")
                                .joins("LEFT JOIN users on vehicle_logs.service_provider_id = users.id")
                                .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                                .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                                .joins("LEFT JOIN workorders on vehicle_logs.workorder_id = workorders.id")
                                .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")

    elsif @current_user.has_role? :service_provider
      vehicle_logs = VehicleLog.select(sel_str)
                              .joins("LEFT JOIN vehicles on vehicles.id = vehicle_logs.vehicle_id")
                              .joins("LEFT JOIN users on vehicle_logs.service_provider_id = users.id")
                              .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                              .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                              .joins("LEFT JOIN workorders on vehicle_logs.workorder_id = workorders.id")
                              .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                              .where(service_provider_id: @current_user.id)
    end

    vehicle_logs = vehicle_logs.where(service_provider_id: @filtered_user.id) if @filtered_user
    vehicle_logs = vehicle_logs.where(vehicle: @vehicle) if @vehicle
    vehicle_logs
  end

   def new_total_records
    sel_str = "vehicle_logs.id"

    if @current_user.has_role? :admin
        vehicle_logs = VehicleLog.select(sel_str)
                                .joins("LEFT JOIN vehicles on vehicles.id = vehicle_logs.vehicle_id")
                                .joins("LEFT JOIN users on vehicle_logs.service_provider_id = users.id")
                                .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                                .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                                .joins("LEFT JOIN workorders on vehicle_logs.workorder_id = workorders.id")
                                .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")

    elsif @current_user.has_role? :service_provider
      vehicle_logs = VehicleLog.select(sel_str)
                              .joins("LEFT JOIN vehicles on vehicles.id = vehicle_logs.vehicle_id")
                              .joins("LEFT JOIN users on vehicle_logs.service_provider_id = users.id")
                              .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                              .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                              .joins("LEFT JOIN workorders on vehicle_logs.workorder_id = workorders.id")
                              .joins("LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id")
                              .where(service_provider_id: @current_user.id)
    end

    vehicle_logs = vehicle_logs.where(service_provider_id: @filtered_user.id) if @filtered_user
    vehicle_logs = vehicle_logs.where(vehicle: @vehicle) if @vehicle
    vehicle_logs.count                        
       
   end


  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[ flagged uid vehicles.model_year vehicle_logs.name workorder_uid service_provider_name odometer_reading updated_at ]
      # columns.delete('vehicle_models.year') if @vehicle
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
