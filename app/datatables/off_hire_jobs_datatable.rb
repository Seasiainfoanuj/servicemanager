class OffHireJobsDatatable
  delegate Fixnum, :params, :h, :can?, :link_to, :number_to_currency, :content_tag, :off_hire_job_status_label, :tag, :job_sp_invoiced_status, to: :@view

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
      recordsFiltered: off_hire_jobs.total_entries,
      data: data
    }
  end

private

  def data
    if @current_user.has_role? :admin
      off_hire_jobs.map do |off_hire_job|
        [
          uid(off_hire_job),
          off_hire_job.name,
          vehicle(off_hire_job),
          off_hire_job_status_label(off_hire_job.status),
          service_provider(off_hire_job),
          sp_invoice(off_hire_job),
          schedule(off_hire_job),
          etc(off_hire_job),
          action_links(off_hire_job)
        ]
      end
    else
      off_hire_jobs.map do |off_hire_job|
        [
          uid(off_hire_job),
          off_hire_job.name,
          vehicle(off_hire_job),
          off_hire_job_status_label(off_hire_job.status),
          service_provider(off_hire_job),
          schedule(off_hire_job),
          etc(off_hire_job),
          action_links(off_hire_job)
        ]
      end
    end
  end

  def action_links(off_hire_job)
    view_link(off_hire_job) + edit_link(off_hire_job)
  end

  def view_link(off_hire_job)
    link_to content_tag(:i, nil, class: 'icon-search'), off_hire_job, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_link(off_hire_job)
    if can? :update, OffHireJob
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "off_hire_jobs", action: "edit", id: off_hire_job.id}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_link(off_hire_job)
    if can? :destroy, OffHireJob
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), off_hire_job, method: :delete, :id => "off_hire_job-#{off_hire_job.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete off hire job number #{off_hire_job.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def uid(off_hire_job)
    link_to content_tag(:span, off_hire_job.uid, class: 'label label-grey'), off_hire_job
  end

  def vehicle(off_hire_job)
    return unless off_hire_job.vehicle_id.present?
    result = []

    name = "#{off_hire_job.model_year} #{off_hire_job.make_name} #{off_hire_job.model_name}" if off_hire_job.model_year.present?
    if can? :read, Vehicle
      result << link_to(name, { controller: "vehicles", action: "show", id: off_hire_job.vehicle_id }) if off_hire_job.model_year.present?
    else
      result << name if off_hire_job.model_year.present?
    end
    result << tag("br")
    result << content_tag(:span, off_hire_job.vehicle_number, class: 'label label-satblue') if off_hire_job.vehicle_number.present?
    result << content_tag(:span, off_hire_job.call_sign, class: 'label label-green') if off_hire_job.call_sign.present?
    result << content_tag(:span, off_hire_job.rego_number, class: 'label label-grey') if off_hire_job.rego_number.present?
    result << content_tag(:span, off_hire_job.vin_number.to_s, class: 'label') if off_hire_job.vin_number.present?
    result.join('')
  end

  def service_provider(off_hire_job)
    unless @current_user.has_role? :service_provider
      if can? :read, User
        return link_to(off_hire_job.service_provider.company_name_short, off_hire_job.service_provider) if off_hire_job.service_provider
      else
        return off_hire_job.service_provider.company_name_short if off_hire_job.service_provider
      end
    end
  end

  def sp_invoice(off_hire_job)
    job_sp_invoiced_status(off_hire_job)
  end

  def schedule(off_hire_job)
    "#{content_tag(:span, off_hire_job.sched_time.strftime("%Y-%m-%d %H-%M"), class: 'hidden')}
        #{off_hire_job.sched_date_field} - <b>#{off_hire_job.sched_time_field}</b>"
  end

  def etc(off_hire_job)
    "#{content_tag(:span, off_hire_job.etc.strftime("%Y-%m-%d %H-%M"), class: 'hidden')}
        #{off_hire_job.etc_date_field} - <b>#{off_hire_job.etc_time_field}</b>"
  end

  def total_records
    init_off_hire_jobs.count
  end

  def off_hire_jobs
    @off_hire_jobs ||= fetch_off_hire_jobs
  end

  def fetch_off_hire_jobs
    off_hire_jobs = init_off_hire_jobs

    if params[:search] && params[:search][:value].present?
      rows = %w[ off_hire_jobs.uid
                  off_hire_jobs.name
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
                  off_hire_jobs.status
                ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      off_hire_jobs = off_hire_jobs.where(search, search_params).order("#{sort_column} #{sort_direction}")
    end

    off_hire_jobs.page(page).per_page(per_page)
  end

  def init_off_hire_jobs
    @pre_off_hire_jobs ||= pre_off_hire_jobs
  end

  def pre_off_hire_jobs
    sel_str = "off_hire_jobs.id, off_hire_jobs.uid, off_hire_jobs.name, off_hire_jobs.status,  off_hire_jobs.service_provider_id,
                  CONCAT(vehicles.model_year, ' ', vehicle_models.name, ' ', vehicle_makes.name) AS vehicle_name,
                  CONCAT(service_providers.company, service_providers.first_name, ' ', service_providers.last_name) AS service_provider_name,
                  service_providers.first_name, service_providers.last_name, service_providers.company, service_providers.email, sp_invoices.status AS sp_invoiced_status,
                  vehicle_id, vehicle_makes.name AS make_name, vehicle_models.name AS model_name, vehicles.model_year, vehicles.call_sign,
                  vehicles.vin_number, vehicles.rego_number, vehicles.stock_number, vehicles.kit_number, vehicles.vehicle_number,
                  off_hire_jobs.sched_time, off_hire_jobs.etc, off_hire_reports.hire_agreement_id, off_hire_jobs.off_hire_report_id"

    if @current_user.has_role? :admin
      off_hire_jobs = OffHireJob.select(sel_str)
                           .joins("LEFT JOIN off_hire_reports on off_hire_jobs.off_hire_report_id = off_hire_reports.id")
                           .joins("LEFT JOIN hire_agreements on off_hire_reports.hire_agreement_id = hire_agreements.id")
                           .joins("LEFT JOIN vehicles on hire_agreements.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on off_hire_jobs.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN sp_invoices on off_hire_jobs.id = sp_invoices.job_id AND sp_invoices.job_type = 'OffHireJob'")
                           .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :service_provider
      off_hire_jobs = OffHireJob.select(sel_str)
                           .joins("LEFT JOIN off_hire_reports on off_hire_jobs.off_hire_report_id = off_hire_reports.id")
                           .joins("LEFT JOIN hire_agreements on off_hire_reports.hire_agreement_id = hire_agreements.id")
                           .joins("LEFT JOIN vehicles on hire_agreements.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on off_hire_jobs.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN sp_invoices on off_hire_jobs.id = sp_invoices.job_id AND sp_invoices.job_type = 'OffHireJob'")
                           .where("off_hire_jobs.service_provider_id = ?", [@current_user.id])
                           .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :customer
      off_hire_jobs = OffHireJob.select(sel_str)
                           .joins("LEFT JOIN off_hire_reports on off_hire_jobs.off_hire_report_id = off_hire_reports.id")
                           .joins("LEFT JOIN hire_agreements on off_hire_reports.hire_agreement_id = hire_agreements.id")
                           .joins("LEFT JOIN vehicles on hire_agreements.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on off_hire_jobs.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN job_subscribers on off_hire_jobs.id = job_subscribers.job_id")
                           .where("job_subscribers.job_type = 'OffHireJob' && job_subscribers.user_id = ?", [@current_user.id])
                           .joins("LEFT JOIN sp_invoices on off_hire_jobs.id = sp_invoices.job_id AND sp_invoices.job_type = 'OffHireJob'")
                           .order("#{sort_column} #{sort_direction}")

    end

    off_hire_jobs = off_hire_jobs.where('vehicles.id = ?', @vehicle.id) if @vehicle
    off_hire_jobs = off_hire_jobs.where('off_hire_jobs.manager_id = :user or off_hire_jobs.service_provider_id = :user',
                                  user: @filtered_user.id) if @filtered_user

    if params[:showAll] && params[:showAll] == 'false'
      off_hire_jobs.where("off_hire_jobs.status != 'complete' && off_hire_jobs.status != 'cancelled'")
    else
      off_hire_jobs
    end
  end

    def new_total_entries
    sel_str = "off_hire_jobs.id"

    if @current_user.has_role? :admin
      off_hire_jobs = OffHireJob.select(sel_str)
                           .joins("LEFT JOIN off_hire_reports on off_hire_jobs.off_hire_report_id = off_hire_reports.id")
                           .joins("LEFT JOIN hire_agreements on off_hire_reports.hire_agreement_id = hire_agreements.id")
                           .joins("LEFT JOIN vehicles on hire_agreements.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on off_hire_jobs.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN sp_invoices on off_hire_jobs.id = sp_invoices.job_id AND sp_invoices.job_type = 'OffHireJob'")
                           .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :service_provider
      off_hire_jobs = OffHireJob.select(sel_str)
                           .joins("LEFT JOIN off_hire_reports on off_hire_jobs.off_hire_report_id = off_hire_reports.id")
                           .joins("LEFT JOIN hire_agreements on off_hire_reports.hire_agreement_id = hire_agreements.id")
                           .joins("LEFT JOIN vehicles on hire_agreements.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on off_hire_jobs.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN sp_invoices on off_hire_jobs.id = sp_invoices.job_id AND sp_invoices.job_type = 'OffHireJob'")
                           .where("off_hire_jobs.service_provider_id = ?", [@current_user.id])
                           .order("#{sort_column} #{sort_direction}")

    elsif @current_user.has_role? :customer
      off_hire_jobs = OffHireJob.select(sel_str)
                           .joins("LEFT JOIN off_hire_reports on off_hire_jobs.off_hire_report_id = off_hire_reports.id")
                           .joins("LEFT JOIN hire_agreements on off_hire_reports.hire_agreement_id = hire_agreements.id")
                           .joins("LEFT JOIN vehicles on hire_agreements.vehicle_id = vehicles.id")
                           .joins("LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                           .joins("LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                           .joins("LEFT JOIN users AS service_providers on off_hire_jobs.service_provider_id = service_providers.id")
                           .joins("LEFT JOIN job_subscribers on off_hire_jobs.id = job_subscribers.job_id")
                           .where("job_subscribers.job_type = 'OffHireJob' && job_subscribers.user_id = ?", [@current_user.id])
                           .joins("LEFT JOIN sp_invoices on off_hire_jobs.id = sp_invoices.job_id AND sp_invoices.job_type = 'OffHireJob'")
                           .order("#{sort_column} #{sort_direction}")

    end

    off_hire_jobs = off_hire_jobs.where('vehicles.id = ?', @vehicle.id) if @vehicle
    off_hire_jobs = off_hire_jobs.where('off_hire_jobs.manager_id = :user or off_hire_jobs.service_provider_id = :user',
                                  user: @filtered_user.id) if @filtered_user

    if params[:showAll] && params[:showAll] == 'false'
      off_hire_jobs = off_hire_jobs.where("off_hire_jobs.status != 'complete' && off_hire_jobs.status != 'cancelled'")
      off_hire_jobs.count  
    else
      off_hire_jobs
      off_hire_jobs.count
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
