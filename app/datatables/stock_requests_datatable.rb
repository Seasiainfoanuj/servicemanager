class StockRequestsDatatable
  delegate :params, :h, :link_to, :can?, :stock_request_status_label, :content_tag, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_records,
      recordsFiltered: stock_requests.total_entries,
      data: data
    }
  end

  private

    def data
      stock_requests.map do |stock_request|
        [
          uid_label(stock_request),
          status_label(stock_request),
          stock_request.company_name,
          supplier_link(stock_request),
          customer_link(stock_request),
          vehicle_make_and_model(stock_request),
          stock_request.transmission_type,
          requested_delivery_date(stock_request),
          action_links(stock_request)
        ]
      end
    end

    def uid_label(stock_request)
      link_to content_tag(:span, stock_request.uid, class: 'label label-grey'), stock_request
    end

    def status_label(stock_request)
      stock_request_status_label(stock_request.status) if stock_request.status.present?
    end

    def supplier_link(stock_request)
      if can? :view, stock_request.supplier
        link_to stock_request.supplier.company_name_short, stock_request.supplier
      else
        stock_request.supplier.company_name_short
      end
    end

    def customer_link(stock_request)
      if stock_request.customer
        if can? :view, stock_request.customer
          link_to stock_request.customer.company_name_short, stock_request.customer
        else
          stock_request.customer.company_name_short
        end
      end
    end

    def vehicle_make_and_model(stock_request)
      "#{stock_request.vehicle_make} #{stock_request.vehicle_model}"
    end

    def requested_delivery_date(stock_request)
      stock_request.requested_delivery_date.strftime("%d/%m/%Y") if stock_request.requested_delivery_date.present?
    end

    def action_links(stock_request)
      view_link(stock_request) + edit_link(stock_request) + destroy_link(stock_request)
    end

    def view_link(stock_request)
      link_to content_tag(:i, nil, class: 'icon-search'), stock_request, {:title => 'View', :class => 'btn action-link'}
    end

    def edit_link(stock_request)
      if can? :update, stock_request
        link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "stock_requests", action: "edit", id: stock_request.uid}, {:title => 'Edit', :class => 'btn action-link'}
      end
    end

    def destroy_link(stock_request)
      if can? :destroy, stock_request
        link_to content_tag(:i, nil, class: 'icon-ban-circle'), stock_request, method: :delete, :id => "stock_request-#{stock_request.id}-del-btn", :class => 'btn action-link stock_request-#{stock_request.id}-del-btn', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete stock request ##{stock_request.uid}. You cannot reverse this action. Are you sure you want to proceed?"}
      end
    end

    def total_records
       init_stock_requests.count
    end

    def stock_requests
      @stock_requests ||= fetch_stock_requests
    end

    def fetch_stock_requests
      stock_requests = init_stock_requests
      if params[:search] && params[:search][:value].present?
        rows = %w[ uid
                   status
                   invoice_companies.name
                   suppliers.first_name
                   suppliers.last_name
                   suppliers.company
                   suppliers.email
                   customers.first_name
                   customers.last_name
                   customers.company
                   customers.email
                   vehicle_make
                   vehicle_model
                   transmission_type
                   requested_delivery_date
                 ]

        terms = params[:search][:value].split
        search_params  = {}
        terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
        search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} LIKE :search#{index}" }.join(" OR ") + ")" }.join(" AND ")

        stock_requests = stock_requests.where(search, search_params).order("#{sort_column} #{sort_direction}")
      end
      stock_requests.page(page).per_page(per_page)
    end

    def init_stock_requests
      @pre_stock_requests ||= pre_stock_requests
    end

    def pre_stock_requests
      sel_str = "stock_requests.id, stock_requests.uid, stock_requests.status, stock_requests.transmission_type,
                 stock_requests.invoice_company_id, stock_requests.supplier_id, stock_requests.customer_id,
                 stock_requests.vehicle_make, stock_requests.vehicle_model,
                 CONCAT(stock_requests.vehicle_make, stock_requests.vehicle_model) AS vehicle_make_and_model,
                 date_format(stock_requests.requested_delivery_date, '%d/%m/%Y') AS requested_delivery_date,
                 date_format(stock_requests.requested_delivery_date, '%Y %m %d') AS requested_delivery_date_sort,
                 CONCAT(suppliers.company, suppliers.first_name, ' ', suppliers.last_name) AS supplier_name,
                 CONCAT(suppliers.first_name, suppliers.last_name, suppliers.email) AS supplier_sort,
                 CONCAT(customers.company, customers.first_name, ' ', customers.last_name) AS customer_name,
                 CONCAT(customers.first_name, customers.last_name, customers.email) AS customer_sort,
                 invoice_companies.name AS company_name"

      stock_requests = StockRequest.select(sel_str)
                                   .joins("LEFT JOIN invoice_companies ON stock_requests.invoice_company_id = invoice_companies.id")
                                   .joins("LEFT JOIN users AS suppliers on stock_requests.supplier_id = suppliers.id")
                                   .joins("LEFT JOIN users AS customers on stock_requests.customer_id = customers.id")

      if @current_user.has_role? :admin
        stock_requests = stock_requests.order("#{sort_column} #{sort_direction}")
      else
        stock_requests = stock_requests.where(supplier_id: @current_user.id).order("#{sort_column} #{sort_direction}")
      end

      stock_requests = stock_requests.where('supplier_id = :user', user: @filtered_user.id) if @filtered_user

      if params[:showAll] && params[:showAll] == 'false'
        stock_requests.where("status != 'closed'")
      else
        stock_requests
      end
    end

    def new_total_records
      sel_str = "stock_requests.id"

      stock_requests = StockRequest.select(sel_str)
      stock_requests.count                             
       
    end

    def page
      params[:start].to_i/per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
        columns = %w[ uid
                      status
                      company_name
                      supplier_sort
                      customer_sort
                      vehicle_make_and_model
                      transmission_type
                      requested_delivery_date_sort
                    ]
        columns[params[:order]["0"][:column].to_i]
      end
    end

    def sort_direction
      if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
    end
end
