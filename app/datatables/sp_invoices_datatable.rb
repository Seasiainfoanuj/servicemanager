class SpInvoicesDatatable
  delegate Fixnum, :params, :h, :can?, :link_to, :content_tag, :tag, :sp_invoice_status_label, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_records,
      recordsFiltered: invoices.total_entries,
      data: data
    }
  end

private

  def data
    invoices ||= fetch_invoices
      invoices.map do |invoice|
        [
          job_uid(invoice),
          job_type(invoice),
          job_sched_date(invoice),
          vehicle(invoice),
          service_provider(invoice),
          invoice.invoice_number,
          status(invoice),
          date_submitted(invoice),
          action_links(invoice)
        ]
      end
  end

  def job_uid(invoice)
    if defined?(invoice.job.uid)
      link_to content_tag(:span, invoice.job.uid, class: 'label label-grey'), invoice.job
    end
  end

  def job_type(invoice)
    if defined?(invoice.job.uid)
      if invoice.job_type == 'Workorder'
        content_tag(:span, invoice.workorder.type.name, class: 'label', style: "background-color: #{invoice.workorder.type.label_color}")
      else
        content_tag(:span, invoice.job_type.titleize, class: 'label label-grey')
      end
    end
  end

  def job_sched_date(invoice)
    if defined?(invoice.job.uid)
      "#{invoice.job.sched_date_field} - #{invoice.job.sched_time_field}"
    end
  end

  def vehicle(invoice)
    if defined?(invoice.job.uid)
      if invoice.job_type == 'Workorder'
        vehicle = invoice.workorder.vehicle
      elsif invoice.job_type == 'BuildOrder'
        vehicle = invoice.build_order.build.vehicle
      elsif invoice.job_type == 'OffHireJob'
        vehicle = invoice.off_hire_job.off_hire_report.hire_agreement.vehicle
      else
        return
     end

    return unless vehicle

    vehicle.name
    result = []
    result << link_to(vehicle.name, vehicle)
    result << tag("br")
    result << content_tag(:span, vehicle.number, class: 'label label-satblue') if vehicle.number.present?
    result << content_tag(:span, vehicle.call_sign, class: 'label label-green') if vehicle.call_sign.present?
    result << content_tag(:span, vehicle.rego_number, class: 'label label-grey') if vehicle.rego_number.present?
    result << content_tag(:span, vehicle.vin_number.to_s, class: 'label') if vehicle.vin_number.present?
    result.join('')
    end
  end

  def service_provider(invoice)
    if defined?(invoice.job.uid)
      link_to(invoice.job.service_provider.company_name_short, invoice.job.service_provider) if invoice.job.service_provider
    end
  end

  def status(invoice)
    sp_invoice_status_label(invoice.status)
  end

  def date_submitted(invoice)
    invoice.created_at.strftime("%d/%m/%Y %I:%M %p")
  end

  def action_links(invoice)
    view_link(invoice) + edit_link(invoice) + destroy_link(invoice)
  end

  def view_link(invoice)
    link_to content_tag(:i, nil, class: 'icon-search'), invoice, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_link(invoice)
    if can? :update, invoice
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "sp_invoices", action: "edit", id: invoice.id}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_link(invoice)
    if can? :destroy, invoice
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), invoice, method: :delete, :id => "invoice-#{invoice.id}-del-btn", :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete invoice #{invoice.invoice_number}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def total_records
    init_invoices.count
  end

  def invoices
    @invoices ||= fetch_invoices
  end

  def fetch_invoices
    invoices = init_invoices

    if params[:search] && params[:search][:value].present?
       rows = %w[ sp_invoices.id
                  sp_invoices.status
                  sp_invoices.invoice_number
                  workorders.uid
                  workorder_service_providers.first_name
                  workorder_service_providers.last_name
                  workorder_service_providers.company
                  workorder_service_providers.email
                  build_order_providers.first_name
                  build_order_providers.last_name
                  build_order_providers.company
                  build_order_providers.email
                  off_hire_job_service_providers.first_name
                  off_hire_job_service_providers.last_name
                  off_hire_job_service_providers.company
                  off_hire_job_service_providers.email
                ]  

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} LIKE :search#{index}" }.join(" OR ") + ")" }.join(" AND ")
  
     invoices = invoices.where(search, search_params)
    end
    invoices.order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
  end

  def init_invoices
    @pre_invoices ||= pre_invoices
  end

  def pre_invoices
    invoices = SpInvoice.joins("LEFT JOIN workorders ON workorders.id = sp_invoices.job_id AND sp_invoices.job_type = 'Workorder'")
                        .joins("LEFT JOIN build_orders ON build_orders.id = sp_invoices.job_id AND sp_invoices.job_type = 'BuildOrder'")
                        .joins("LEFT JOIN off_hire_jobs ON off_hire_jobs.id = sp_invoices.job_id AND sp_invoices.job_type = 'OffHireJob'")
                        .joins("LEFT JOIN users AS workorder_service_providers on workorders.service_provider_id = workorder_service_providers.id")
                        .joins("LEFT JOIN users AS build_order_providers on build_orders.service_provider_id = build_order_providers.id")
                        .joins("LEFT JOIN users AS off_hire_job_service_providers on off_hire_jobs.service_provider_id = off_hire_job_service_providers.id")

    if params[:showAll] && params[:showAll] == 'false'
      invoices.where("sp_invoices.status != 'processed'")
    else
      invoices
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
      columns = %w[workorders.uid sp_invoices.job_type sp_invoices.job_type sp_invoices.id sp_invoices.id sp_invoices.invoice_number sp_invoices.status sp_invoices.created_at]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
