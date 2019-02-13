class NotificationsDatatable
  delegate :params, :h, :link_to, :can?, :tag, :content_tag, :notification_label, :notification_type_label, to: :@view

  def initialize(view, current_user, notifiable_type, notifiable_id)
    @view = view
    @current_user = current_user
    @notifiable_type = notifiable_type
    @notifiable_id = notifiable_id
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_records,
      recordsFiltered: notifications.total_entries.to_i,
      data: data
    }
  end

private

  def data
    if @current_user.has_role? :admin
      notifications.map do |notification|
        [
          notification_type(notification),
          resource_name(notification),
          emails_used(notification),
          due_date(notification),
          completed_date(notification),
          action_links(notification)
        ]
      end
    end
  end

  def notification_type(notification)
    background_color = notification.label_color.downcase
    link_to content_tag(:span, notification.event_full_name, class: 'label', style: "background-color: #{background_color}"), {controller: 'notification_types', :action => 'show', :id => notification.notification_type_id}
  end

  def resource_name(notification)
    if notification.notifiable_type == 'Vehicle'
      result = []
      result << link_to(notification.vehicle_name, { controller: "vehicles", action: "show", id: notification.notifiable_id }) if notification.notifiable_id.present?
      result << tag("br")
      result << content_tag(:span, notification.vehicle_number, class: 'label label-satblue') if notification.vehicle_number.present?
      result << content_tag(:span, notification.call_sign, class: 'label label-green') if notification.call_sign.present?
      result << content_tag(:span, notification.rego_number, class: 'label label-grey') if notification.rego_number.present?
      result << content_tag(:span, notification.vin_number.to_s, class: 'label') if notification.vin_number.present?
      result.join('')
    end  
  end

  def emails_used(notification)
    notification.emails_required ? 'Yes' : 'No'
  end

  def due_date(notification)
    notification.due_date.strftime("%d/%m/%Y")
  end

  def completed_date(notification)
    notification.completed_date.strftime("%d/%m/%Y") if notification.completed_date
  end

  def action_links(notification)
    view_link(notification) + edit_link(notification) + action_taken_link(notification)
  end

  def view_link(notification)
    link_to content_tag(:i, nil, class: 'icon-search'), notification, {title: 'View', class: 'btn action-link', rel: 'tooltip'}
  end

  def edit_link(notification)
    if (can? :update, Notification) && notification.completed_date.nil?
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "notifications", action: "edit", id: notification.id}, {title: 'Edit', class: 'btn action-link'}
    end  
  end

  def action_taken_link(notification)
    if (can? :complete, Notification) && notification.completed_date.nil?
      link_to content_tag(:i, nil, class: 'glyphicon glyphicon-certificate'), {controller: "notifications", action: "record_action", id: notification.id}, { title: "Record Action Taken", class: 'btn action-link' }
    end
  end

  def total_records
    init_notifications.count
  end

  def notifications
    @notifications ||= fetch_notifications
  end

  def fetch_notifications
    notifications = init_notifications
    count = nil

    if params[:search] && params[:search][:value].present? && params[:search][:value].length > 3
      rows = %w[ notification_types.resource_name
                 notification_types.event_name
                 vehicles.model_year
                 vehicle_models.name
                 vehicle_makes.name
                 due_date
                 completed_date
               ]
      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      notifications = notifications.where(search, search_params)  # .order("#{sort_column} #{sort_direction}")
      count = notifications.length
    end

    notifications.page(page).per_page(per_page)
  end

  def init_notifications
    @pre_notifications ||= pre_notifications
  end

  def pre_notifications
    sel_str = "notifications.id, notifications.due_date, notifications.completed_date, 
               notifications.notifiable_id, notifications.notifiable_type, 
               notifications.notification_type_id, notification_types.label_color,
               notification_types.emails_required, notification_types.resource_name, notification_types.event_name,
               vehicles.model_year, vehicle_models.name, vehicle_makes.name,
               CONCAT(notification_types.resource_name, ' / ', notification_types.event_name) AS event_full_name,
               CONCAT(vehicles.model_year, ' ', vehicle_models.name, ' ', vehicle_makes.name) AS vehicle_name,
               vehicles.vehicle_number, vehicles.call_sign, vehicles.rego_number, vehicles.vin_number"

    notifications = Notification.select(sel_str)
        .joins("LEFT JOIN notification_types on notifications.notification_type_id = notification_types.id")
        .joins("LEFT JOIN vehicles on notifications.notifiable_id = vehicles.id AND notifications.notifiable_type = 'Vehicle'")          
        .joins("LEFT JOIN vehicle_models AS vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
        .joins("LEFT JOIN vehicle_makes AS vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
        .order("completed_date ASC, due_date ASC")
        # .order("#{sort_column} #{sort_direction}").order("#{sort_column} #{sort_direction}")

    
    notifications = notifications.where('notifiable_id = ? AND notifiable_type = ?', @notifiable_id, @notifiable_type) if @notifiable_id
    if params[:showAll] && params[:showAll] == 'false'
      notifications.not_completed
    else
      notifications
    end
  end

  def new_total_records
    sel_str = "notifications.id"

    notifications = Notification.select(sel_str)
        .joins("LEFT JOIN notification_types on notifications.notification_type_id = notification_types.id")
        .joins("LEFT JOIN vehicles on notifications.notifiable_id = vehicles.id AND notifications.notifiable_type = 'Vehicle'")          
        .joins("LEFT JOIN vehicle_models AS vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
        .joins("LEFT JOIN vehicle_makes AS vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
        .order("completed_date ASC, due_date ASC")
        # .order("#{sort_column} #{sort_direction}").order("#{sort_column} #{sort_direction}")

    
    notifications = notifications.where('notifiable_id = ? AND notifiable_type = ?', @notifiable_id, @notifiable_type) if @notifiable_id
    if params[:showAll] && params[:showAll] == 'false'
      notifications.not_completed
    else
      notifications.count
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
      columns = %w[event_full_name 
                   vehicle_name
                   emails_required 
                   due_date 
                   completed_date]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end

end
