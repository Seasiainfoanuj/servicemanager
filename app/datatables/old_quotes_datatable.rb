class QuotesDatatable
  delegate :params, :h, :link_to, :can?, :content_tag, :quote_status_label, :number_to_currency, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
    @filtered_user = User.find(params[:filtered_user]) if params[:filtered_user]
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_entries,
      recordsFiltered: quotes.total_entries,
      data: data
    }
  end

private

  def data
    if @current_user.has_role? :admin
      quotes.map do |quote|
        [
          number(quote),
          quote.quote_date,
          customer(quote),
          company(quote),
          number_to_currency(quote_total(quote)),
          quote_status_label(quote.status),
          quote.tag_names,
          action_links(quote)
        ]
      end
    else
      quotes.map do |quote|
        [
          number(quote),
          quote.quote_date,
          number_to_currency(quote_total(quote)),
          action_links(quote)
        ]
      end
    end
  end

  def number(quote)
    link_to content_tag(:span, quote.number, class: "label label-grey"), quote
  end

  # avoid n+1 queries problem, duplicates User.name
  def customer(quote)
    link_to(quote.customer.name, quote.customer)
  end

  def company(quote)
    link_to(quote.customer.company, quote.customer) if quote.customer.company
  end

  def quote_total(quote)
    quote.total_cents.to_f/100 if quote.total_cents.present?
  end

  def action_links(quote)
    view_link(quote) + amendment_link(quote) + edit_link(quote) + cancel_link(quote)
  end

  def view_link(quote)
    link_to content_tag(:i, nil, class: 'icon-search'), quote, {:title => 'View', :class => 'btn action-link'}
  end

  def amendment_link(quote)
    if can? :update, Quote && QuoteStatus.action_permitted?(:create_amendment, quote.status)
      link_to content_tag(:i, nil, class: 'icon-paste'), {:action => 'create_amendment', :quote_id => quote.quote_id}, :title => 'Create Amendment', :class => 'btn action-link', 'rel' => 'tooltip', "data-placement" => "bottom", data: {confirm: "You are about to cancel this quote and create an ammended copy. Are you sure you want to do this?"}
    end
  end

  def edit_link(quote)
    if (can? :update, Quote) && QuoteStatus.action_permitted?(:update, quote.status)
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "quotes", action: "edit", id: quote.number}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def cancel_link(quote)
    if can? :cancel, Quote
      unless quote.status == 'cancelled'
        link_to content_tag(:i, nil, class: 'icon-ban-circle'), {controller: "quotes", action: "cancel", quote_id: quote.number}, :class => 'btn action-link', :title => 'Cancel', 'rel' => 'tooltip', data: {confirm: "You are about to cancel quote number #{quote.number}. Are you sure you want to proceed?"}
      end
    end
  end

  def total_entries
    init_quotes.count.length
  end

  def quotes
    @quotes ||= fetch_quotes
  end

  def fetch_quotes
    quotes = init_quotes

    if params[:search] && params[:search][:value].present? && params[:search][:value].length > 3

      search_items_flag = '#'

      rows = %w[ number
                 status
                 po_number
                 total_cents
                 customer_first_name
                 customer_last_name
                 customer_email
                 customer_company
                 managers.first_name
                 managers.last_name
                 managers.email
                 managers.company
                 tag_names
               ]
      item_rows = %w[ name description ]

      search_items = params[:search][:value].include? search_items_flag
      search = params[:search][:value].delete "#{search_items_flag},"
      search_params  = {}

      terms = search.split
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }

      if search_items
        search = terms.map.with_index {|term, index| "(" + item_rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

        quote_item_ids = QuoteItem.where(search, search_params).pluck(:quote_id)
        quotes = quotes.where(id: quote_item_ids).load
      else # TODO: find out how to combine so both tables are searchable .. currently one or the other
        search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

        quotes = quotes.having(search, search_params)
      end

      count = quotes.length
    end

    quotes = quotes.page(page).per_page(per_page).order("#{sort_column} #{sort_direction}, number desc")
    quotes.total_entries = count || quotes.count.length
    quotes
  end

  def init_quotes
    @pre_quotes ||= pre_quotes
  end

  def pre_quotes
    sel_str = "quotes.id AS quote_id, quotes.number, quotes.total_cents, quotes.status, quotes.po_number, quotes.manager_id, quotes.customer_id,
               date_format(quotes.date, '%d/%m/%Y') AS quote_date, date_format(quotes.date, '%Y%m%d') AS quote_date_sort,
               managers.first_name, managers.last_name, managers.email, managers.company,
               customers.first_name AS customer_first_name, customers.last_name AS customer_last_name,
               customers.email AS customer_email, customers.company AS customer_company,
               CONCAT(customers.first_name, customers.last_name, customers.email) AS customer_sort,
               tags.id, taggings.tag_id, GROUP_CONCAT(tags.name SEPARATOR ', ') AS tag_names"

    if @current_user.has_role? :admin
      quotes = Quote.select(sel_str)
                    .joins("LEFT JOIN users AS customers on quotes.customer_id = customers.id")
                    .joins("LEFT JOIN users AS managers on quotes.manager_id = managers.id")
                    .joins("LEFT JOIN taggings ON taggings.taggable_id = quotes.id AND taggings.taggable_type = 'Quote'")
                    .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
                    .group('quotes.id')

    else
      quotes = Quote.select(sel_str)
                    .joins("LEFT JOIN users AS customers on quotes.customer_id = customers.id")
                    .joins("LEFT JOIN users AS managers on quotes.manager_id = managers.id")
                    .joins("LEFT JOIN taggings ON taggings.taggable_id = quotes.id AND taggings.taggable_type = 'Quote'")
                    .joins("LEFT JOIN tags on taggings.tag_id = tags.id")
                    .group('quotes.id')
                    .where("customer_id = :user", user: @current_user.id)

    end

    quotes = quotes.where('manager_id = :user or customer_id = :user', user: @filtered_user.id) if @filtered_user

    if params[:showAll] && params[:showAll] == 'false'
      quotes.where("quotes.status != 'cancelled' AND quotes.updated_at > ?", Date.today - DEFAULT_QUOTE_HISTORY_MONTHS.months)
    else
      quotes
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
        columns = %w[number quote_date_sort customer_sort customer_company total_cents status tag_names]
      else
        columns = %w[number quote_date_sort total_cents]
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
