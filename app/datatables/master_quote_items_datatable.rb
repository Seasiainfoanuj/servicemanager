class MasterQuoteItemsDatatable
  delegate :params, :h, :link_to, :can?, :number_to_currency, :truncate, to: :@view

  def initialize(view, current_user, mode = nil)
    @view = view
    @current_user = current_user
    @mode = mode
  end

  def as_json(options = {})
    {
      draw: params[:draw].to_i,
      recordsTotal: new_total_records,
      recordsFiltered: master_quote_items.total_entries,
      data: data
    }
  end

private

  def data
    if @mode == 'add_to_quote'
      master_quote_items.map do |master_quote_item|
      
        [
          master_quote_item.item_type_name,
          master_quote_item.name,
          truncate(master_quote_item.description, :length => 80),
          number_to_currency(master_quote_item.cost_cents/100),
          master_quote_item.tag_names,
          action_links(master_quote_item)
        ]
      end
    else
      master_quote_items.map do |master_quote_item|
         puts "#{master_quote_item.item_type_name}"
        
        [
          master_quote_item.item_type_name,
          master_quote_item.name,
          truncate(master_quote_item.description, :length => 80),
          number_to_currency(master_quote_item.buy_price_cents/100),
          number_to_currency(master_quote_item.cost_cents/100),
          master_quote_item.tag_names,
          action_links(master_quote_item)
        ]
      end
    end
  end

  def action_links(master_quote_item)
    if @mode == 'add_to_quote'
      master_quote_item.cost_tax ? cost_tax_id = master_quote_item.cost_tax.id : cost_tax_id = 0
      link_to('<i class="icon-plus-sign"></i>'.html_safe, "#",
        :id => "master-quote-item-#{master_quote_item.id}",
        :class => "add_master_quote_item_fields btn btn-grey",
        "data-id" => master_quote_item.id,
        "data-supplier-id" => master_quote_item.supplier_id,
        "data-service-provider-id" => master_quote_item.service_provider_id,
        "data-quote-item-type-id" => master_quote_item.quote_item_type_id,
        "data-name" => master_quote_item.name,
        "data-description" => master_quote_item.description,
        "data-cost" => master_quote_item.cost,
        "data-tax-id" => master_quote_item.cost_tax_id,
        "data-buy-price" => master_quote_item.buy_price,
        "data-buy-price-tax-id" => master_quote_item.buy_price_tax_id,
        "data-quantity" => master_quote_item.quantity
      )
    else
      edit_link(master_quote_item) + destroy_link(master_quote_item)
    end
  end

  def edit_link(master_quote_item)
    if can? :update, MasterQuoteItem
      link_to('<i class="icon-edit"></i>'.html_safe, {controller: "master_quote_items", action: "edit", id: master_quote_item.id}, {:title => 'Edit', :class => 'btn action-link'})
    end
  end

  def destroy_link(master_quote_item)
    if can? :destroy, MasterQuoteItem
      link_to '<i class="icon-ban-circle"></i>'.html_safe, master_quote_item, method: :delete, :class => 'btn action-link', :title => 'Destroy', 'rel' => 'tooltip', data: {confirm: "You are about to permanently delete #{master_quote_item.name}. You cannot reverse this action. Are you sure you want to proceed?"}
    end
  end

  def master_quote_items
    @master_quote_items ||= fetch_master_quote_items
  end

  def fetch_master_quote_items
    master_quote_items = init_master_quote_items

    if params[:search] && params[:search][:value].present?
      rows = %w[ item_types.name
                 master_quote_items.name
                 description
                 buy_price_cents
                 cost_cents
                 tag_names
               ]

      terms = params[:search][:value].split
      search_params  = {}
      terms.each_with_index { |term, index| search_params["search#{index}".to_sym] = "%#{term}%" }
      search = terms.map.with_index {|term, index| "(" + rows.map { |row| "#{row} LIKE :search#{index}" }.join(" OR ") + ")" }.join(" AND ")

      master_quote_items = master_quote_items.having(search, search_params)
      count = master_quote_items.length
    end

    master_quote_items = master_quote_items.page(page).per_page(per_page).order("#{sort_column} #{sort_direction}")
    master_quote_items.total_entries = count || master_quote_items.count.length
    master_quote_items
  end

  def init_master_quote_items
    @pre_master_quote_items ||= pre_master_quote_items
  end

  def pre_master_quote_items
    sel_str = "master_quote_items.id,
               master_quote_items.quote_item_type_id,
               master_quote_items.supplier_id,
               master_quote_items.service_provider_id,
               item_types.name AS item_type_name,
               item_types.sort_order,
               master_quote_items.name,
               master_quote_items.description,
               master_quote_items.buy_price_cents,
               master_quote_items.cost_cents,
               master_quote_items.cost_tax_id,
               master_quote_items.buy_price_tax_id,
               master_quote_items.quantity,
               GROUP_CONCAT(tags.name SEPARATOR ', ') AS tag_names"

    master_quote_items = MasterQuoteItem.select(sel_str)
              .joins("LEFT JOIN taggings ON taggings.taggable_id = master_quote_items.id AND taggings.taggable_type = 'MasterQuoteItem'")
              .joins("LEFT JOIN tags ON tags.id = taggings.tag_id")
              .joins("LEFT JOIN quote_item_types AS item_types ON item_types.id = master_quote_items.quote_item_type_id")
              .group("master_quote_items.id")
    master_quote_items
  end

   def new_total_records
      sel_str = "master_quote_items.id"
      master_quote_items = MasterQuoteItem.select(sel_str)
              .joins("LEFT JOIN taggings ON taggings.taggable_id = master_quote_items.id AND taggings.taggable_type = 'MasterQuoteItem'")
              .joins("LEFT JOIN tags ON tags.id = taggings.tag_id")
              .joins("LEFT JOIN quote_item_types AS item_types ON item_types.id = master_quote_items.quote_item_type_id")
              .group("master_quote_items.id")
      master_quote_items = master_quote_items.count
    end
 
  def total_entries
    init_master_quote_items.count
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    if params[:order] && params[:order]["0"] && params[:order]["0"][:column]
      columns = %w[item_types.name master_quote_items.name description buy_price_cents cost_cents tag_names]
      columns[params[:order]["0"][:column].to_i]
    end
  end

  def sort_direction
    if params[:order] && params[:order]["0"] && params[:order]["0"][:dir]
      params[:order]["0"][:dir] == "asc" ? "asc" : "desc"
    end
  end
end
