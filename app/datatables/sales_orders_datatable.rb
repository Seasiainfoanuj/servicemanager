class SalesOrdersDatatable
  delegate :params, :h, :link_to, :can?, :truncate, :number_to_currency, :content_tag, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_entries,
      recordsFiltered: sales_orders.total_entries,
      data: data
    }
  end

private

  def data
    if @current_user.has_role? :admin
      sales_orders.map do |sales_order|
        [
          number(sales_order),
          order_date(sales_order),
          customer(sales_order),
          company(sales_order),
          quote(sales_order),
          build(sales_order),
          deposit_received(sales_order),
          last_milestone(sales_order),
          action_links(sales_order)
        ]
      end
    else
      sales_orders.map do |sales_order|
        [
          number(sales_order),
          order_date(sales_order),
          quote(sales_order),
          deposit_received(sales_order),
          last_milestone(sales_order),
          action_links(sales_order)
        ]
      end
    end
  end

  def number(sales_order)
    link_to content_tag(:span, sales_order.number, class: "label label-grey"), sales_order
  end

  def order_date(sales_order)
    sales_order.order_date.strftime("%d/%m/%Y")
  end

  def customer(sales_order)
    link_to sales_order.customer.name, sales_order.customer
  end

  def company(sales_order)
    if sales_order.customer.representing_company
      link_to sales_order.customer.representing_company.short_name, sales_order.customer.representing_company
    end
  end

  def quote(sales_order)
    link_to sales_order.quote.number, sales_order.quote if sales_order.quote && can?(:read, sales_order.quote)
  end

  def build(sales_order)
    link_to sales_order.build.number, sales_order.build if sales_order.build
  end

  def deposit_received(sales_order)
    output = ""
    if sales_order.deposit_received?
      output += content_tag(:span, content_tag(:i, "", class: "icon-ok") + "", class: "label label-satgreen") + " "
    end
    if sales_order.deposit_required_cents > 0
      output += number_to_currency(sales_order.deposit_required_cents.to_f/100)
    end
    output
  end

  def last_milestone(sales_order)
    milestones = sales_order.milestones.where(completed: true)
    if milestones.present?
      truncate(milestones.last.description, :length => 80)
    end
  end

  def action_links(sales_order)
    view_link(sales_order) + edit_link(sales_order) + cancel_link(sales_order)
  end

  def view_link(sales_order)
    link_to content_tag(:i, nil, class: 'icon-search'), sales_order, {:title => 'View', :class => 'btn action-link'}
  end

  def edit_link(sales_order)
    if can? :update, SalesOrder
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "sales_orders", action: "edit", id: sales_order.number}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def cancel_link(sales_order)
    if can? :destroy, SalesOrder
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), sales_order, method: :delete, :id => "sales-order-#{sales_order.id}-del-btn", :class => 'btn action-link sales-order-#{sales_order.id}-del-btn', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete sales order ##{sales_order.number}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def total_entries
     init_sales_orders.count
  end

  def sales_orders
    @sales_orders ||= fetch_sales_orders
  end

  def fetch_sales_orders
    sales_orders = init_sales_orders

    if params[:search] && params[:search][:value].present?
      rows = %w[
        sales_orders.number
        quotes.number
        builds.number
        customers.first_name
        customers.last_name
        customers.email
        managers.first_name
        managers.last_name
        managers.email
        managers.company
      ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")
      sales_orders = sales_orders.where(search, search_params).order("#{sort_column} #{sort_direction}")
    end

    sales_orders.page(page).per_page(per_page)
  end

  def init_sales_orders
    @pre_sales_orders ||= pre_sales_orders
  end

  def pre_sales_orders
    sel_str = "sales_orders.id, sales_orders.number, sales_orders.order_date, sales_orders.deposit_received, sales_orders.deposit_required_cents,
               sales_orders.quote_id, sales_orders.build_id, sales_orders.customer_id, sales_orders.manager_id"

    if @current_user.has_role? :admin
      sales_orders = SalesOrder.select(sel_str)
                               .joins("LEFT JOIN quotes on sales_orders.quote_id = quotes.id")
                               .joins("LEFT JOIN builds on sales_orders.quote_id = builds.id")
                               .joins("LEFT JOIN sales_order_milestones on sales_order_milestones.sales_order_id = sales_orders.id")
                               .joins("LEFT JOIN users AS customers on sales_orders.customer_id = customers.id")
                               .joins("LEFT JOIN users AS managers on sales_orders.manager_id = managers.id")
                               .group("sales_orders.id")
    else
      sales_orders = SalesOrder.select(sel_str)
                    .joins("LEFT JOIN quotes on sales_orders.quote_id = quotes.id")
                    .joins("LEFT JOIN builds on sales_orders.quote_id = builds.id")
                    .joins("LEFT JOIN sales_order_milestones on sales_order_milestones.sales_order_id = sales_orders.id")
                    .joins("LEFT JOIN users AS customers on sales_orders.customer_id = customers.id")
                    .joins("LEFT JOIN users AS managers on sales_orders.manager_id = managers.id")
                    .where("sales_orders.customer_id = :user", user: @current_user.id)
                    .group("sales_orders.id")

    end

    sales_orders = sales_orders.where('manager_id = :user or customer_id = :user', user: @filtered_user.id) if @filtered_user
    sales_orders.order("#{sort_column} #{sort_direction}")
  end

  def new_total_entries
    sel_str = "sales_orders.id"

    if @current_user.has_role? :admin
      sales_orders = SalesOrder.select(sel_str)
                                .joins("LEFT JOIN quotes on sales_orders.quote_id = quotes.id")
                                .joins("LEFT JOIN builds on sales_orders.quote_id = builds.id")
                                .joins("LEFT JOIN sales_order_milestones on sales_order_milestones.sales_order_id = sales_orders.id")
                                .joins("LEFT JOIN users AS customers on sales_orders.customer_id = customers.id")
                                .joins("LEFT JOIN users AS managers on sales_orders.manager_id = managers.id")
                                .group("sales_orders.id")
    else
      sales_orders = SalesOrder.select(sel_str)
                    .joins("LEFT JOIN quotes on sales_orders.quote_id = quotes.id")
                    .joins("LEFT JOIN builds on sales_orders.quote_id = builds.id")
                    .joins("LEFT JOIN sales_order_milestones on sales_order_milestones.sales_order_id = sales_orders.id")
                    .joins("LEFT JOIN users AS customers on sales_orders.customer_id = customers.id")
                    .joins("LEFT JOIN users AS managers on sales_orders.manager_id = managers.id")
                    .where("sales_orders.customer_id = :user", user: @current_user.id)
                    .group("sales_orders.id")
   
    end

    sales_orders = sales_orders.where('manager_id = :user or customer_id = :user', user: @filtered_user.id) if @filtered_user
    sales_orders.count
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[ sales_orders.number order_date customers.last_name quotes.number builds.number sales_orders.deposit_received]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
