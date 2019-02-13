class SavedQuoteItemsDatatable
  delegate :params, :h, :can?, :link_to, :number_to_currency, :truncate, :content_tag, to: :@view

  def initialize(view, current_user, mode = nil)
    @view = view
    @current_user = current_user
    @mode = mode
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: total_records,
      recordsFiltered: saved_quote_items.total_entries,
      data: data
    }
  end

private

  def data
    saved_quote_items.map do |saved_quote_item|
      [
        saved_quote_item.name,
        truncate(saved_quote_item.description, :length => 80),
        number_to_currency(saved_quote_item.cost_cents/100),
        action_links(saved_quote_item)
      ]
    end
  end

  def action_links(saved_quote_item)
    if @mode == 'add_to_quote'
      tax_id = saved_quote_item.tax ? saved_quote_item.tax.id : 0
      link_to content_tag(:i, nil, class: 'icon-plus-sign'), "#", :class => "add_saved_item_fields btn btn-grey", "data-name" => saved_quote_item.name, "data-description" => saved_quote_item.description, "data-cost" => saved_quote_item.cost, "data-quantity" => saved_quote_item.quantity, "data-tax-id" => tax_id
    else
      edit_link(saved_quote_item) + destroy_link(saved_quote_item)
    end
  end

  def edit_link(saved_quote_item)
    if can? :update, SavedQuoteItem
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "saved_quote_items", action: "edit", id: saved_quote_item.id}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def destroy_link(saved_quote_item)
    if can? :destroy, SavedQuoteItem
      link_to content_tag(:i, nil, class: 'icon-ban-circle'), saved_quote_item, method: :delete, :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete #{saved_quote_item.name}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def saved_quote_items
    @saved_quote_items ||= fetch_saved_quote_items
  end

  def fetch_saved_quote_items
    saved_quote_items = init_saved_quote_items

    if params[:search] && params[:search][:value].present?
      rows = %w[ name
                  description
               ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} like :search#{index}" }.join(" or ") + ")" }.join(" and ")

      saved_quote_items = saved_quote_items.where(search, search_params).order("#{sort_column} #{sort_direction}")
    end

    saved_quote_items.page(page).per_page(per_page)
  end

  def init_saved_quote_items
    @pre_saved_quote_items ||= pre_saved_quote_items
  end

  def pre_saved_quote_items
    saved_quote_items = SavedQuoteItem.order("#{sort_column} #{sort_direction}")
  end

  def total_records
    init_saved_quote_items.count
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[name description cost_cents]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
