class ClientsDatatable
  
  delegate :params, :h, :can?, :link_to, :content_tag, to: :@view

  def initialize(view, current_user, mode)
    @view = view
    @current_user = current_user
    @mode = mode
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_records,
      recordsFiltered: clients.total_entries,
      data: data
    }
  end

  private

    def data
      clients.map do |client|
        [
          reference_number(client),
          client.client_type.titleize,
          company_name(client),
          first_name(client),
          last_name(client),
          email(client),
          action_links(client)
        ]
      end
    end

    def reference_number(client)
      link_to(content_tag(:span, client.reference_number, class: 'label'), "/clients/#{client.reference_number}")
    end

    def company_name(client)
      if client.client_type == "person"
        client.employer_name or client.contact_company_name
      else
        client.company_client_name or client.employer_name
      end  
    end

    def first_name(client)
      client.user_first_name
    end

    def last_name(client)
      client.user_last_name
    end

    def email(client)
      client.user_email
    end

    def action_links(client)
      view_link(client) + edit_link(client)
    end

    def view_link(client)
      if client.client_type == "person"
        link_to content_tag(:i, nil, class: 'icon-search'), "/users/#{client.user_id}", {:title => 'View person', :class => 'btn action-link'}
      elsif client.company_client_name.present?
        link_to content_tag(:i, nil, class: 'icon-search'), "/companies/#{client.company_client_id}", {:title => 'View company', :class => 'btn action-link'}
      else  
        ""  
      end  
    end

    def edit_link(client)
      if client.client_type == "person"
        link_to content_tag(:i, nil, class: 'icon-edit'), "/users/#{client.user_id}/edit", {:title => 'Edit person', :class => 'btn action-link'}
      elsif client.company_client_name.present?
        link_to content_tag(:i, nil, class: 'icon-edit'), "/companies/#{client.company_client_id}/edit", {:title => 'Edit company', :class => 'btn action-link'}
      else
        ""  
      end  
    end

    def total_records
      init_clients.count
    end

    def clients
      @clients ||= fetch_clients
    end

    def fetch_clients
      clients = init_clients

      if params[:search] && params[:search][:value].present?
        rows = %w[ reference_number
                    client_type
                    users.first_name
                    users.last_name
                    users.email
                    companies.name
                    contact_companies.name
                  ]

        terms = params[:search][:value].split
        search_params  = {}
        terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
        search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

        clients = clients.where(search, search_params).order("#{sort_column} #{sort_direction}")
      end

      clients.page(page).per_page(per_page)
    end

    def init_clients
      @pre_clients ||= pre_clients
    end

    def pre_clients
      selstr = "clients.id, clients.reference_number, clients.client_type, clients.user_id,
                 users.first_name AS user_first_name, users.last_name AS user_last_name,
                 users.email AS user_email, users.first_name, users.last_name, users.email,
                 employers.name, companies.name, contact_companies.name, 
                 companies.name AS company_client_name, companies.id AS company_client_id,
                 contact_companies.name AS company_name,
                 employers.name AS employer_name, contact_companies.name AS contact_company_name"
      clients = Client.select(selstr)
                .joins("LEFT JOIN users on clients.user_id = users.id")
                .joins("LEFT JOIN companies on clients.company_id = companies.id")
                .joins("LEFT JOIN companies AS contact_companies on users.representing_company_id = contact_companies.id")
                .joins("LEFT JOIN invoice_companies AS employers on users.employer_id = employers.id")
    end
    
    def new_total_records
      sel_str = "clients.id"
      clients = Client.select(sel_str)
                .joins("LEFT JOIN users on clients.user_id = users.id")
                .joins("LEFT JOIN companies on clients.company_id = companies.id")
                .joins("LEFT JOIN companies AS contact_companies on users.representing_company_id = contact_companies.id")
                .joins("LEFT JOIN invoice_companies AS employers on users.employer_id = employers.id")
      clients.count
    end
    
    def page
      params[:start].to_i/per_page + 1
    end  

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
        columns = %w[id reference_number client_type user_first_name user_last_name user_email contact_company_name ]
        columns[params[:order]["0"][:column].to_i]
      end
    end

    def sort_direction
      if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
        params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
      end
    end

end