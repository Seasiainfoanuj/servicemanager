class VehiclesDatatable
  include VehiclesHelper
  
  delegate :params, :h, :can?, :link_to, :content_tag, to: :@view

  def initialize(view, current_user, mode)
    @view = view
    @current_user = current_user
    @mode = mode
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_records,
      recordsFiltered: vehicles.total_entries,
      data: data
    }
  end

  private

    def data
      vehicles.map do |vehicle|
        [
          vehicle_number(vehicle),
          vehicle.vin_number,
          vehicle.vehicle_model,
          vehicle.stock_number,
          vehicle.transmission,
          rego_number(vehicle),
          owner_link(vehicle),
          vehicle_status_label(vehicle.status),
          action_links(vehicle)
        ]
      end
    end

    def vehicle_number(vehicle)
      link_to content_tag(:span, vehicle.vehicle_number, class: 'label label-satblue') +
        content_tag(:span, vehicle.call_sign, class: 'label label-green'), vehicle
    end

    def rego_number(vehicle)
      content_tag(:span, vehicle.rego_number, class: 'label')
    end

    def owner_link(vehicle)
      if can? :read, User
        link_to(vehicle.owner.company_name_short, vehicle.owner) if vehicle.owner
      else
        vehicle.owner.company_name_short if vehicle.owner
      end
    end

    def action_links(vehicle)
      view_link(vehicle) + edit_link(vehicle) + destroy_link(vehicle)
    end

    def view_link(vehicle)
      link_to content_tag(:i, nil, class: 'icon-search'), vehicle, {:title => 'View', :class => 'btn action-link'}
    end

    def edit_link(vehicle)
      if can? :update, Vehicle
        link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "vehicles", action: "edit", id: vehicle.id}, {:title => 'Edit', :class => 'btn action-link'}
      end
    end

    def destroy_link(vehicle)
      if can? :destroy, Vehicle
        link_to content_tag(:i, nil, class: 'icon-ban-circle'), vehicle, method: :delete, :id => "vehicle-#{vehicle.id}-del-btn", :class => 'btn action-link vehicle-#{vehicle.id}-del-btn', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete vehicle ##{vehicle.number} VIN# #{vehicle.vin_number}. You cannot reverse this action. Are you sure you want to proceed?"}
      end
    end

    def total_records
      init_vehicles.count
    end

    def vehicles
      @vehicles ||= fetch_vehicles
    end

    def fetch_vehicles
      vehicles = init_vehicles

      if params[:search] && params[:search][:value].present?
        rows = %w[ vehicle_number
                    vin_number
                    engine_number
                    rego_number
                    call_sign
                    class_type
                    kit_number
                    stock_number
                    license_required
                    seating_capacity
                    transmission
                    status
                    model_year
                    vehicle_models.name
                    vehicle_makes.name
                    users.first_name
                    users.last_name
                    users.email
                    users.company
                 ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      vehicles = vehicles.where(search, search_params).order("#{sort_column} #{sort_direction}")
      end

      vehicles.page(page).per_page(per_page)
    end

    def init_vehicles
      @pre_vehicles ||= pre_vehicles
    end

    def pre_vehicles
      sel_str = "vehicles.id, vehicle_number, vin_number, engine_number, rego_number, call_sign, model_year, 
                 stock_number, class_type, kit_number, license_required, seating_capacity, transmission, 
                 vehicle_model_id, owner_id, status, vehicle_models.name, vehicle_makes.name, 
                 users.first_name, users.last_name, users.email, users.company,
                 CONCAT(vehicles.model_year, ' ', vehicle_makes.name, ' ', vehicle_models.name) AS vehicle_model"

      if @current_user.has_role? :admin
        vehicles = Vehicle.select(sel_str)
                          .joins("LEFT JOIN users on vehicles.owner_id = users.id")
                          .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                          .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                          .order("#{sort_column} #{sort_direction}").order("#{sort_column} #{sort_direction}")

      elsif @current_user.has_role? :supplier
        vehicles = Vehicle.select(sel_str)
                          .where(:supplier_id => @current_user.id)
                          .joins("LEFT JOIN users on vehicles.owner_id = users.id")
                          .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                          .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                          .order("#{sort_column} #{sort_direction}")

      elsif @current_user.has_role? :customer
        vehicles = Vehicle.select(sel_str)
                          .where(:owner_id => @current_user.id)
                          .joins("LEFT JOIN users on vehicles.owner_id = users.id")
                          .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                          .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                          .order("#{sort_column} #{sort_direction}")
      end

      vehicles = vehicles.joins(:hire_details).where('active') if @mode == "hire_vehicles"
      vehicles = vehicles.where('owner_id = :user or supplier_id = :user', user: @filtered_user.id) if @filtered_user
      vehicles
    end

    def new_total_records
      sel_str = "vehicles.id"

      if @current_user.has_role? :admin
        vehicles = Vehicle.select(sel_str)
        vehicles.count                  

      elsif @current_user.has_role? :supplier
        vehicles = Vehicle.select(sel_str)
                          .where(:supplier_id => @current_user.id)
        vehicles.count

      elsif @current_user.has_role? :customer
        vehicles = Vehicle.select(sel_str)
                          .where(:owner_id => @current_user.id)
        vehicles.count
      end

      vehicles = vehicles.joins(:hire_details).where('active') if @mode == "hire_vehicles"
      vehicles = vehicles.where('owner_id = :user or supplier_id = :user', user: @filtered_user.id) if @filtered_user
      vehicles.count
    end
    
    def page
      params[:start].to_i/per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
        columns = %w[vehicle_number vin_number vehicle_model stock_number transmission rego_number vehicle_number status]
        columns[params[:order]["0"][:column].to_i]
      end
    end

    def sort_direction
      if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
    end
end
