class StocksDatatable
  delegate :params, :h, :link_to, :can?, :content_tag, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_records,
      recordsFiltered: stocks.total_entries,
      data: data
    }
  end

private

  def data
    stocks.map do |stock|
      [
        number(stock),
        stock.vin_number,
        stock.name,
        stock.transmission,
        supplier_link(stock),
        stock.eta_date_field,
        action_links(stock)
      ]
    end
  end

  def supplier_link(stock)
    if can? :read, User
      link_to(stock.supplier.company_name_short, stock.supplier)
    else
      stock.supplier.company_name_short
    end
  end

  def action_links(stock)
    view_link(stock) + edit_link(stock) + destroy_link(stock)
  end

  def view_link(stock)
    link_to content_tag(:i, nil, class: 'icon-search'), stock, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_link(stock)
    if can? :update, Stock
      link_to content_tag(:i, nil, class: 'icon-edit') , {controller: "stocks", action: "edit", id: stock.id}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_link(stock)
    if can? :destroy, Stock
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), stock, method: :delete, :id => "stock-#{stock.id}-del-btn", :class => 'btn action-link stock-#{stock.id}-del-btn', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete stock ##{stock.number} VIN# #{stock.vin_number}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def number(stock)
    link_to content_tag(:span, stock.stock_number, class: "label label-grey"), stock
  end

  def total_records
     init_stocks.count
  end

  def stocks
    @stocks ||= fetch_stocks
  end

  def fetch_stocks
    stocks = init_stocks

    if params[:search] && params[:search][:value].present?
      rows = %w[ name
                  stock_number
                  year
                  vin_number
                  engine_number
                  first_name
                  last_name
                  email
               ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      stocks = stocks.joins(:supplier, :model).where(search, search_params).order("#{sort_column} #{sort_direction}")

    end

    stocks.page(page).per_page(per_page)
  end

  def init_stocks
    @pre_stocks ||= pre_stocks
  end

  def pre_stocks
    if @current_user.has_role? :admin
      stocks = Stock.joins(:supplier, :model).order("#{sort_column} #{sort_direction}")
    else
      stocks = Stock.where(:supplier_id => @current_user.id).joins(:supplier, :model).order("#{sort_column} #{sort_direction}")
    end

    stocks = stocks.where('supplier_id = :user', user: @filtered_user.id) if @filtered_user
    stocks
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[stock_number vin_number year stock_number first_name eta]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
