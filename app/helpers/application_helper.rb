module ApplicationHelper

  def present(model)
    klass = "#{model.class}Presenter".constantize
    presenter = klass.new(model, self)
    yield(presenter) if block_given?
  end

  def flash_class(level)
    case level
      when :notice then "alert alert-info"
      when :success then "alert alert-success"
      when :error then "alert alert-error"
      when :alert then "alert alert-alert"
    end
  end

  def active_class_for_controller(controller_name)
    params[:controller].eql?(controller_name) ? 'active' : nil
  end

  def active_class_for_controller_action(controller_name, action_name)
    (params[:controller].eql?(controller_name) && params[:action].eql?(action_name)) ? 'active' : nil
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name.html_safe, '#', class: "add_fields btn btn-lightgrey", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def display_date(date, options = {})
    return "" if date == nil
    case options[:format]
      when :short
        date.strftime("%d/%m/%Y")
      when :month  
        date.strftime("%B %Y")
      else
        date.strftime("%d %B %Y")
    end
  end

  def display_time(time)
    time.strftime("%d %B %Y at %H:%M")
  end

  def schedule_view_subitems
    tags = ""
    ScheduleView.all.each do |schedule_view|
      class_name = (params[:controller] == 'schedule_views' && params[:schedule_view_id] == schedule_view.id) ? 'active' : ''
      tags << content_tag(:li, link_to(schedule_view.name, schedule_view, data: { no_turbolink: true }), :class => class_name)
    end  
    tags.html_safe
  end

  def quotes_link
    class_name = params[:controller] == 'quotes' ? 'active' : ''
    label_name = (can? :create, Quote) ? 'Manage Quotes' : 'View Quotes'
    content_tag(:li, link_to(label_name, quotes_path), class: class_name)
  end

  def manual_link(page)
    content_tag(:span, link_to(image_tag('book.png'), "/user_guides/#{page}"), class: 'manual')
  end

  def notifications_link
    class_name = params[:controller] == 'notifications' ? 'active' : ''
    content_tag(:li, link_to('Manage Notifications', notifications_path), class: class_name)
  end

  def options_for_invoice_company_names
    InvoiceCompany.all.collect { |cpy| [cpy.name, cpy.id] }
  end

  def options_for_tax
    
    Tax.all.collect { |tax| [tax.name, tax.id] }
  end
  
  def options_managers(options = {})
    if options[:show_company] == true
     User.where('roles_mask IN (1, 65, 129, 257)').includes(:representing_company).collect do |user|
        if user.representing_company
          ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
      end
    else
     User.where('roles_mask IN (1, 65, 129, 257)').collect { |user| ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]}
    end 
  end  
  
  def admin_managers(options = {})
   if options[:show_company] == true
     User.where('roles_mask IN (1, 65, 129, 257, 513)').includes(:representing_company).collect do |user|
        if user.representing_company
          ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
      end
    else
     User.where('roles_mask IN (1, 65, 129, 257, 513)').collect { |user| ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]}
   end 
  end 

  def option_for_dealer(options = {})
   if options[:show_company] == true
     User.where( :id => current_user.id).includes(:representing_company).collect do |user|
        if user.representing_company
          ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
      end
    else
     User.where(:id => current_user.id).collect { |user| ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]}
   end 
  end   

  def options_for_admin(options = {})
    if options[:show_company] == true
     User.where('roles_mask = 1').includes(:representing_company).collect do |user|
        if user.representing_company
          ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
      end
    else
      User.where('roles_mask = 1').collect { |user| ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]}
    end
  end

  def options_for_admin_users(options = {})
    if options[:show_company] == true
      User.admin.includes(:representing_company).collect do |user|
        if user.representing_company
          ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
      end
    else
      User.admin.collect { |user| ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]}
    end
  end

   def options_for_employee(options = {})
    if options[:show_company] == true
      User.employee.includes(:representing_company).collect do |user|
        if user.representing_company
          ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
      end
    else
      User.employee.collect { |user| ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]}
    end
   end

  def options_for_users(options = {})
    all_users = User.includes(:representing_company)
    if options[:id] == :email
      all_users.collect do |user|
        if user.representing_company.present?
          ["#{user.representing_company.name} #{user.first_name} #{user.last_name} #{user.email}", user.email]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.email]
        end
      end
    else
      all_users.collect do |user|
        if user.representing_company.present?
          ["#{user.representing_company.name} #{user.first_name} #{user.last_name} #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
      end
    end
  end  

  def options_for_customers
    users = User.non_admin.includes(:representing_company)
    users.collect do |user| 
      if user.representing_company
        ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
      else
        ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
      end
    end
  end

  def options_for_enquiriers(user_id, options = {})
   if options[:show_company] == true
     User.where(:id => user_id ).includes(:representing_company).collect do |user|
        if user.representing_company
          ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
        else
          ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
        end
     end
   else
      User.where(:id => user_id ).collect { |user| ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]}
   end
  end

  def query_totals(total_records, current_page, per_page) 
    return "" if (total_records == 0)
    current_page = 1 if current_page == 0
    entries_previous_pages = current_page == 0 ? 0 : per_page * (current_page - 1)
    first_entry = entries_previous_pages + 1
    if total_records > per_page * current_page
      last_entry = first_entry + per_page - 1
    else
      last_entry = total_records
    end  
    "Showing #{number_with_delimiter(first_entry)} to #{number_with_delimiter(last_entry)} entries (filtered from #{number_with_delimiter(total_records)} total entries)"
  end

end



