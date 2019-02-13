class BuildsDatatable
  delegate Fixnum, :params, :h, :can?, :link_to, :build_order_progress_class, :number_to_percentage, :content_tag, :tag, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_entries,
      recordsFiltered: builds.total_entries,
      data: data
    }
  end

private

  def data
    builds.map do |build|
      [
        build_number(build),
        vehicle(build),
        build_orders(build),
        action_links(build)
      ]
    end
  end

  def action_links(build)
    view_link(build) + edit_link(build) + destroy_link(build)
  end

  def view_link(build)
    link_to content_tag(:i, nil, class: 'icon-search'), build, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_link(build)
    if can? :update, Build
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "builds", action: "edit", id: build.id}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_link(build)
    if can? :destroy, Build
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), build, method: :delete, :id => "build-#{build.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete build number #{build.number}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def build_number(build)
    link_to content_tag(:span, build.number, class: 'label label-grey'), build
  end

  def vehicle(build)
    return unless build.vehicle_id.present?
    result = []

    name = "#{build.model_year} #{build.make_name} #{build.model_name}" if build.model_year.present?
    if can? :read, Vehicle
      result << link_to(name, { controller: "vehicles", action: "show", id: build.vehicle_id }) if build.model_year.present?
    else
      result << name if build.model_year.present?
    end
    result << tag("br")
    result << content_tag(:span, build.vehicle_number, class: 'label label-satblue') if build.vehicle_number.present?
    result << content_tag(:span, build.call_sign, class: 'label label-green') if build.call_sign.present?
    result << content_tag(:span, build.rego_number, class: 'label label-grey') if build.rego_number.present?
    result << content_tag(:span, build.vin_number.to_s, class: 'label') if build.vin_number.present?
    result.join('')
  end

  def build_orders(build)
    return if build.build_orders.empty?
    result = "<table class='progress-table smooth'><tr>"
    build.build_orders.where.not(status: 'cancelled').sort { |a,b| a.sched_time <=> b.sched_time }.each do |build_order|
      result += "<td width='#{number_to_percentage(100/build.build_orders.length)}'>"
      result += link_to "<span><b>##{build_order.uid}</b> - #{build_order.name} - #{build_order.status.capitalize}</span>".html_safe, build_order, {:class => "btn #{build_order_progress_class(build_order.status)} progress-link", 'rel' => 'popover', 'data-trigger' => 'hover', 'data-placement' => 'bottom', 'data-original-title' => "#{build_order.name} ##{build_order.uid}", 'data-content' => "Scheduled Start  #{build_order.sched_time_field} - #{build_order.service_provider.name} - Estimated to be complete at #{build_order.etc_time_field} #{build_order.etc_date_field}", id: "popover-build-order"}
      result += "</td>"
    end
    result + "</tr></table>"
  end

  def total_entries
    init_builds.length
  end

  def builds
    @builds ||= fetch_builds
  end

  def fetch_builds
    builds = init_builds

    if params[:search] && params[:search][:value].present?
      rows = %w[ number
                  rego_number
                  stock_number
                  kit_number
                  vehicle_number
                  call_sign
                  vehicle_makes.name
                  vehicles.model_year
                  vehicle_models.name
                  first_name
                  last_name
                  email
                  company
                  build_orders.uid
                  build_orders.name
                  build_orders.status
                ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")
      builds = builds.where(search, search_params).order("#{sort_column} #{sort_direction}")
    end

    builds.page(page).per_page(per_page)
  end

  def init_builds
    @pre_builds ||= pre_builds
  end

  def pre_builds
    sel_str = "builds.id, builds.number, builds.manager_id, build_orders.uid, build_orders.name, build_orders.status,
               users.first_name, users.last_name, users.email, users.company,
               vehicle_id, vehicle_makes.name AS make_name, vehicle_models.name AS model_name,
               vehicles.model_year, vehicles.call_sign, vehicles.rego_number, vehicles.stock_number, vehicles.kit_number,
               vehicles.vehicle_number, vehicles.vin_number"

    builds = Build.select(sel_str)
                  .joins("LEFT JOIN build_orders on build_orders.build_id = builds.id")
                  .joins("LEFT JOIN vehicles on vehicles.id = builds.vehicle_id")
                  .joins("LEFT JOIN users on builds.manager_id = users.id")
                  .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                  .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                  .group('builds.id')

    builds = builds.where('users.id = :user', user: @filtered_user) if @filtered_user
    builds.order("#{sort_column} #{sort_direction}")
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[number vehicles.model_year]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
