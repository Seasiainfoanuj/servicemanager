class BuildOrdersDatatable
  delegate Fixnum, :params, :h, :can?, :link_to, :number_to_currency, :content_tag, :build_order_status_label, :tag, :job_sp_invoiced_status, to: :@view

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
      recordsFiltered: build_orders.total_entries,
      data: data
    }
  end

  private
    def data
      if @current_user.has_role? :admin 
        build_orders.map do |build_order|
          [
            uid(build_order),
            build_order.name,
            vehicle(build_order),
            build_order_status_label(build_order.status),
            service_provider(build_order),
            sp_invoice(build_order),
            schedule(build_order),
            etc(build_order),
            action_links(build_order)
          ]
        end
      else
        build_orders.map do |build_order|
          [
            uid(build_order),
            build_order.name,
            vehicle(build_order),
            build_order_status_label(build_order.status),
            service_provider(build_order),
            schedule(build_order),
            etc(build_order),
            action_links(build_order)
          ]
        end
      end
    end

    def uid(build_order)
      link_to content_tag(:span, build_order.uid, class: 'label label-grey'), build_order
    end

    def vehicle(build_order)
      return unless build_order.vehicle_id.present?
      result = []

      name = "#{build_order.model_year} #{build_order.make_name} #{build_order.model_name}" if build_order.model_year.present?
      if can? :read, Vehicle
        result << link_to(name, { controller: "vehicles", action: "show", id: build_order.vehicle_id }) if build_order.model_year.present?
      else
        result << name if build_order.model_year.present?
      end
      result << tag("br")
      result << content_tag(:span, build_order.vehicle_number, class: 'label label-satblue') if build_order.vehicle_number.present?
      result << content_tag(:span, build_order.call_sign, class: 'label label-green') if build_order.call_sign.present?
      result << content_tag(:span, build_order.rego_number, class: 'label label-grey') if build_order.rego_number.present?
      result << content_tag(:span, build_order.vin_number.to_s, class: 'label') if build_order.vin_number.present?
      result.join('')
    end

    def service_provider(build_order)
      unless @current_user.has_role? :service_provider
        if can? :read, User
          return link_to(build_order.service_provider.company_name_short, build_order.service_provider) if build_order.service_provider
        else
          return build_order.service_provider.company_name_short if build_order.service_provider
        end
      end
    end

    def sp_invoice(build_order)
      job_sp_invoiced_status(build_order)
    end

    def schedule(build_order)
      "#{content_tag(:span, build_order.sched_time.strftime("%Y-%m-%d %H-%M"), class: 'hidden')}
          #{build_order.sched_date_field} - <b>#{build_order.sched_time_field}</b>"
    end

    def etc(build_order)
      "#{content_tag(:span, build_order.etc.strftime("%Y-%m-%d %H-%M"), class: 'hidden')}
          #{build_order.etc_date_field} - <b>#{build_order.etc_time_field}</b>"
    end

    def action_links(build_order)
      view_link(build_order) + edit_link(build_order)
    end

    def view_link(build_order)
      link_to content_tag(:i, nil, class: 'icon-search'), build_order, {:title => 'View', :class => 'btn action-link'}
    end

    def edit_link(build_order)
      if can? :update, BuildOrder
        link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "build_orders", action: "edit", id: build_order.id}, {:title => 'Edit', :class => 'btn action-link'}
      end
    end

    def destroy_link(build_order)
      if can? :destroy, BuildOrder
        link_to content_tag(:i, nil, class: 'icon-ban-circle'), build_order, method: :delete, :id => "build_order-#{build_order.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete off hire job number #{build_order.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
      end
    end

    def total_records
      init_build_orders.count
    end

    def build_orders
      @build_orders ||= fetch_build_orders
    end

    def fetch_build_orders
      build_orders = init_build_orders

      if params[:search] && params[:search][:value].present?
        rows = %w[ build_orders.uid
                   build_orders.name
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
                   sp_invoices.status
                   build_orders.status
                 ]

        terms = params[:search][:value].split
        search_params  = {}
        terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
        search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

        build_orders = build_orders.where(search, search_params).order("#{sort_column} #{sort_direction}")
      end

      build_orders.page(page).per_page(per_page)
    end

    def init_build_orders
      @pre_build_orders ||= pre_build_orders
    end

    def pre_build_orders
      sel_str = "build_orders.id, build_orders.uid, build_orders.name, build_orders.status,  build_orders.service_provider_id,
                    CONCAT(vehicles.model_year, ' ', vehicle_models.name, ' ', vehicle_makes.name) AS vehicle_name,
                    CONCAT(service_providers.company, service_providers.first_name, ' ', service_providers.last_name) AS service_provider_name,
                    service_providers.first_name, service_providers.last_name, service_providers.company, service_providers.email, sp_invoices.status AS sp_invoiced_status,
                    vehicle_id, vehicle_makes.name AS make_name, vehicle_models.name AS model_name, vehicles.model_year, vehicles.call_sign,
                    vehicles.vin_number, vehicles.rego_number, vehicles.stock_number, vehicles.kit_number, vehicles.vehicle_number,
                    build_orders.sched_time, build_orders.etc, build_orders.build_id"

      if @current_user.has_role? :admin
        build_orders = BuildOrder.select(sel_str)
                             .joins("LEFT JOIN builds on build_orders.build_id = builds.id")
                             .joins("LEFT JOIN vehicles on builds.vehicle_id = vehicles.id")
                             .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                             .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                             .joins("LEFT JOIN users AS service_providers on build_orders.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN sp_invoices on build_orders.id = sp_invoices.job_id AND sp_invoices.job_type = 'BuildOrder'")
                             .order("#{sort_column} #{sort_direction}")

      elsif @current_user.has_role? :service_provider
        build_orders = BuildOrder.select(sel_str)
                             .joins("LEFT JOIN builds on build_orders.build_id = builds.id")
                             .joins("LEFT JOIN vehicles on builds.vehicle_id = vehicles.id")
                             .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                             .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                             .joins("LEFT JOIN users AS service_providers on build_orders.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN sp_invoices on build_orders.id = sp_invoices.job_id AND sp_invoices.job_type = 'BuildOrder'")
                             .where("build_orders.service_provider_id = ?", [@current_user.id])
                             .order("#{sort_column} #{sort_direction}")

      elsif @current_user.has_role? :customer
        build_orders = BuildOrder.select(sel_str)
                             .joins("LEFT JOIN builds on build_orders.build_id = builds.id")
                             .joins("LEFT JOIN vehicles on builds.vehicle_id = vehicles.id")
                             .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                             .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                             .joins("LEFT JOIN users AS service_providers on build_orders.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN job_subscribers on build_orders.id = job_subscribers.job_id")
                             .where("job_subscribers.job_type = 'BuildOrder' && job_subscribers.user_id = ?", [@current_user.id])
                             .joins("LEFT JOIN sp_invoices on build_orders.id = sp_invoices.job_id AND sp_invoices.job_type = 'BuildOrder'")
                             .order("#{sort_column} #{sort_direction}")

      end

      build_orders = build_orders.where('vehicles.id = ?', @vehicle.id) if @vehicle
      build_orders = build_orders.where('build_orders.manager_id = :user or build_orders.service_provider_id = :user',
                                    user: @filtered_user.id) if @filtered_user

      if params[:showAll] && params[:showAll] == 'false'
        build_orders.where("build_orders.status != 'complete' && build_orders.status != 'cancelled'")
      else
        build_orders
      end
    end


    def new_total_entries
      sel_str = "build_orders.id"

      if @current_user.has_role? :admin
        build_orders = BuildOrder.select(sel_str)
                             .joins("LEFT JOIN builds on build_orders.build_id = builds.id")
                             .joins("LEFT JOIN vehicles on builds.vehicle_id = vehicles.id")
                             .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                             .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                             .joins("LEFT JOIN users AS service_providers on build_orders.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN sp_invoices on build_orders.id = sp_invoices.job_id AND sp_invoices.job_type = 'BuildOrder'")
                             .order("#{sort_column} #{sort_direction}")

      elsif @current_user.has_role? :service_provider
        build_orders = BuildOrder.select(sel_str)
                             .joins("LEFT JOIN builds on build_orders.build_id = builds.id")
                             .joins("LEFT JOIN vehicles on builds.vehicle_id = vehicles.id")
                             .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                             .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                             .joins("LEFT JOIN users AS service_providers on build_orders.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN sp_invoices on build_orders.id = sp_invoices.job_id AND sp_invoices.job_type = 'BuildOrder'")
                             .where("build_orders.service_provider_id = ?", [@current_user.id])
                             .order("#{sort_column} #{sort_direction}")

      elsif @current_user.has_role? :customer
        build_orders = BuildOrder.select(sel_str)
                             .joins("LEFT JOIN builds on build_orders.build_id = builds.id")
                             .joins("LEFT JOIN vehicles on builds.vehicle_id = vehicles.id")
                             .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                             .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                             .joins("LEFT JOIN users AS service_providers on build_orders.service_provider_id = service_providers.id")
                             .joins("LEFT JOIN job_subscribers on build_orders.id = job_subscribers.job_id")
                             .where("job_subscribers.job_type = 'BuildOrder' && job_subscribers.user_id = ?", [@current_user.id])
                             .joins("LEFT JOIN sp_invoices on build_orders.id = sp_invoices.job_id AND sp_invoices.job_type = 'BuildOrder'")
                             .order("#{sort_column} #{sort_direction}")

      end

      build_orders = build_orders.where('vehicles.id = ?', @vehicle.id) if @vehicle
      build_orders = build_orders.where('build_orders.manager_id = :user or build_orders.service_provider_id = :user',
                                    user: @filtered_user.id) if @filtered_user

      if params[:showAll] && params[:showAll] == 'false'
       build_orders= build_orders.where("build_orders.status != 'complete' && build_orders.status != 'cancelled'")
       build_orders.count
      else
        build_orders
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
        if @current_user.has_role? :admin
          columns = %w[uid name vehicle_name status service_provider_name sp_invoiced_status sched_time etc]
        else
          columns = %w[uid name vehicle_name status service_provider_name sched_time etc]
        end
        columns[params[:order]["0"][:column].to_i]
      end
    end

    def sort_direction
      if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
        params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
      end
    end

end
