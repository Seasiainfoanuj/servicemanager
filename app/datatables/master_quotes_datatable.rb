class MasterQuotesDatatable
  delegate :params, :h, :can?, :link_to, :content_tag, :number_to_currency, to: :@view

  def initialize(view, current_user)
    @view = view
    @current_user = current_user
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_entries,
      recordsFiltered: master_quotes.total_entries,
      data: data
    }
  end

private

  def data
    master_quotes.where("international IS ?", nil).map do |quote|
      [
        name(quote),
        quote.type.name,
        quote.vehicle_make,
        quote.vehicle_model,
        seating_number(quote),
        quote.transmission_type,
        number_to_currency(quote.grand_total),
        action_links(quote)
      ]
    end
  end

  def name(quote)
    link_to content_tag(:span, quote.name, class: "label label-grey"), quote
  end

  def seating_number(quote)
    "#{quote.seating_number} " + content_tag(:span, "+ Driver", style: 'color: #888;')
  end

  def action_links(quote)
    if  @current_user.has_role? :masteradmin , :superadmin 
      view_link(quote) + edit_link(quote) + destroy_link(quote) 
    else
      view_link(quote)
    end
  end

  def view_link(quote)
    link_to('<i class="icon-search"></i>'.html_safe, quote, {:title => 'View', :class => 'btn action-link'})
  end

  def edit_link(quote)
    if can? :update, MasterQuote
      link_to('<i class="icon-edit"></i>'.html_safe, {controller: "master_quotes", action: "edit", id: quote.id}, {:title => 'Edit', :class => 'btn action-link'})
    end
  end

  def destroy_link(quote)
    if can? :destroy, MasterQuote
      link_to '<i class="icon-ban-circle"></i>'.html_safe, quote, method: :delete, :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete quote number #{quote.name}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end
  

  
  def total_entries
    MasterQuote.count
  end

  def master_quotes
    @master_quotes ||= fetch_master_quotes
  end

  def fetch_master_quotes
    master_quotes = init_master_quotes

    if params[:search] && params[:search][:value].present?
      rows = %w[ master_quote_types.name
                master_quotes.name
                master_quotes.vehicle_make
                master_quotes.vehicle_model
                master_quotes.seating_number
                master_quotes.transmission_type
             ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      master_quotes = master_quotes.where(search, search_params).order("#{sort_column} #{sort_direction}")
    end

   master_quotes.page(page).per_page(per_page)
  end

  def init_master_quotes
    @pre_master_quotes ||= pre_master_quotes
  end

  def pre_master_quotes
    master_quotes = MasterQuote.joins("LEFT JOIN master_quote_types on master_quotes.master_quote_type_id = master_quote_types.id")
                               .order("#{sort_column} #{sort_direction}")
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[name master_quote_types.name vehicle_make vehicle_model seating_number transmission_type]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
