class VehicleContractsDatatable
  
  delegate :params, :h, :can?, :link_to, :content_tag, :tag, :vehicle_contract_status_label, to: :@view

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
      recordsFiltered: vehicle_contracts.total_entries,
      data: data
    }
  end

  private

    def data
      vehicle_contracts.map do |contract|
        [
          uid(contract),
          quote_number(contract),
          vehicle(contract),
          customer(contract),
          status(contract),
          action_links(contract)
        ]
      end
    end

    def uid(contract)
      if @current_user.admin?
        link_to content_tag(:span, contract.uid, class: 'label label-grey'), contract
      elsif can? :view_customer_contract, VehicleContract
        link_to content_tag(:span, contract.uid, class: 'label'), {controller: "vehicle_contracts", action: "view_customer_contract", id: contract.uid}, {:title => 'View Customer Contract'}
      end
    end

    def quote_number(contract)
      quote = contract.quote
      if can? :read, Quote
        link_to content_tag(:span, quote.number, class: 'label'), quote
      else
        quote.number
      end
    end

    def vehicle(contract)
      if contract.vehicle_id.present?
        result = own_vehicle_stock(contract)
      else
        return nil
      end
      result.join('')
    end

    def own_vehicle_stock(contract)
      result = []
      if can? :read, Vehicle
        result << link_to(contract.vehicle_name, { controller: "vehicles", action: "show", id: contract.vehicle_id })
      else
        result << contract.vehicle_name
      end
      result << tag("br")
      result << content_tag(:span, contract.vehicle_number, class: 'label label-satblue') if contract.vehicle_number.present?
      result << content_tag(:span, contract.call_sign, class: 'label label-green') if contract.call_sign.present?
      result << content_tag(:span, contract.rego_number, class: 'label label-grey') if contract.rego_number.present?
      result << content_tag(:span, contract.vin_number, class: 'label') if contract.vin_number.present?
      result
    end

    def customer(contract)
      if can? :read, User
        link_to(contract.customer_name, contract.quote.customer)
      else
        contract.customer_name
      end
    end

    def status(contract)
      vehicle_contract_status_label(contract.current_status)
    end

    def action_links(contract)
      view_link(contract) + edit_link(contract) + review_link(contract) + contract_link(contract)
    end

    def view_link(contract)
      if @current_user.admin?
        link_to content_tag(:i, nil, class: 'icon-search'), contract, {:title => 'View', :class => 'btn action-link'}
      else
        ""
      end 
    end

    def contract_link(contract)
      if can? :view_customer_contract, VehicleContract
        link_to content_tag(:i, nil, class: 'icon-legal'), {controller: "vehicle_contracts", action: "view_customer_contract", id: contract.uid}, {:title => 'View Customer Contract', :class => 'btn action-link'}
      else
        ""
      end
    end

    def edit_link(contract)
      if can? :update, VehicleContract
        link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "vehicle_contracts", action: "edit", id: contract.uid}, {:title => 'Edit', :class => 'btn action-link'}
      else
        ""
      end
    end

    def review_link(contract)
      options = { current_status: contract.current_status } 
      if (can? :review, VehicleContract) && VehicleContractStatusManager.action_permitted?(:accept, options)
        link_to content_tag(:i, nil, class: 'icon-comments-alt'), {controller: "vehicle_contracts", action: "review", id: contract.uid}, {:title => 'Review Contract', :class => 'btn action-link'}
      else
        ""
      end
    end

    def total_entries
      init_vehicle_contracts.count
    end

    def vehicle_contracts
      @vehicle_contracts ||= fetch_vehicle_contracts
    end

    def fetch_vehicle_contracts
      contracts = init_vehicle_contracts

      if params[:search] && params[:search][:value].present? && params[:search][:value].length > 3
        search_items_flag = '#'
        rows = %w[ uid
                   quote_number
                   vehicle_name
                   customer_name
                   current_status
                 ]

        item_rows = %w[ name description ]
        search_items = params[:search][:value].include? search_items_flag
        search = params[:search][:value].delete "#{search_items_flag},"
        search_params  = {}
        terms = search.split
        terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }

        if search_items
          search = terms.map.with_index {|term, index| "(" + item_rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")
          contract_ids = VehicleContract.where(search, search_params).pluck(:vehicle_contract_id)
          contracts = contracts.where(id: contract_ids).load
        else
          search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")
          contracts = contracts.having(search, search_params)
        end  

        count = contracts.length
      end

      contracts = contracts.page(page).per_page(per_page).order("#{sort_column} #{sort_direction}, number desc")
      contracts.total_entries = count || contracts.count
      contracts
    end

    def init_vehicle_contracts
      @pre_vehicle_contracts ||= pre_vehicle_contracts
    end

    def pre_vehicle_contracts
      sel_str = "vehicle_contracts.id AS vehicle_contract_id, vehicle_contracts.uid, quotes.number AS quote_number, vehicle_contracts.quote_id,
                 CONCAT(vehicles.model_year, ' ', vehicle_models.name, ' ', vehicle_makes.name) AS vehicle_name,
                 vehicles.vehicle_number, vehicles.call_sign, vehicles.rego_number, vehicles.vin_number,
                 CONCAT(customers.first_name, ' ', customers.last_name) AS customer_name,
                 vehicle_contracts.vehicle_id, vehicle_contracts.allocated_stock_id, vehicle_contracts.current_status, 
                 customers.id AS customer_id"

      if @current_user.has_role? :admin
        contracts = VehicleContract.select(sel_str)
                          .joins("LEFT JOIN quotes on vehicle_contracts.quote_id = quotes.id")
                          .joins("LEFT JOIN vehicles on vehicle_contracts.vehicle_id = vehicles.id")
                          .joins("LEFT JOIN stocks on vehicle_contracts.allocated_stock_id = stocks.id")
                          .joins("LEFT JOIN users AS customers on vehicle_contracts.customer_id = customers.id")
                          .joins("LEFT JOIN vehicle_models AS vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                          .joins("LEFT JOIN vehicle_makes AS vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
      else
        contracts = VehicleContract.select(sel_str)
                          .joins("LEFT JOIN quotes on vehicle_contracts.quote_id = quotes.id")
                          .joins("LEFT JOIN vehicles on vehicle_contracts.vehicle_id = vehicles.id")
                          .joins("LEFT JOIN stocks on vehicle_contracts.allocated_stock_id = stocks.id")
                          .joins("LEFT JOIN users AS customers on vehicle_contracts.customer_id = customers.id")
                          .joins("LEFT JOIN vehicle_models AS vehicle_models on vehicles.vehicle_model_id = vehicle_models.id")
                          .joins("LEFT JOIN vehicle_makes AS vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id")
                          .where("vehicle_contracts.customer_id = ?", @current_user.id)
                          .where("vehicle_contracts.current_status IN ('presented_to_customer', 'signed')")
      end

      contracts
    end

    def new_total_records
      sel_str = "vehicle_contracts.id"

      if @current_user.has_role? :admin
        contracts = VehicleContract.select(sel_str)
        contracts.count
      else
        contracts = VehicleContract.select(sel_str)
                          .where("vehicle_contracts.customer_id = ?", @current_user.id)
                          .where("vehicle_contracts.current_status IN ('presented_to_customer', 'signed')")
        contracts.count  
    end
        contracts.count
    end

    def page
      params[:start].to_i/per_page + 1
    end

    def per_page
      params[:length].to_i > 0 ? params[:length].to_i : 10
    end

    def sort_column
      if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
        columns = %w[uid quote_number vehicle_name customer_name current_status]
        columns[params[:order]["0"][:column].to_i]
      end
    end

    def sort_direction
      if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
        params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
      end
    end
end
