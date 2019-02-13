module QuotesHelper

  def link_to_add_saved_fields(name, f, association, saved_item_data)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name.html_safe, '#', class: "add_saved_fields btn btn-satgreen", data: {id: id, fields: fields.gsub("\n", ""), saved_item: saved_item_data})
  end

  def quote_status_label(status)
    if status == 'draft'
      "<span class='label'>#{status.capitalize}</span>".html_safe
    elsif status == 'updated'
      "<span class='label label-satblue'>#{status.capitalize}</span>".html_safe
    elsif status == 'sent'
      "<span class='label label-blue'>#{status.capitalize}</span>".html_safe
    elsif status == 'resent'
      "<span class='label label-blue'>#{status.capitalize}</span>".html_safe
    elsif status == 'viewed'
      "<span class='label label-grey'>#{status.capitalize}</span>".html_safe
    elsif status == 'accepted'
      "<span class='label label-green'>#{status.capitalize}</span>".html_safe
    elsif status == 'changes requested'
      "<span class='label label-orange'>#{status.capitalize}</span>".html_safe
    elsif status == 'cancelled'
      "<span class='label label-red'>#{status.capitalize}</span>".html_safe
    else
      "<span class='label'>Draft</span>".html_safe
    end
  end

  def quote_action_links(quote_id)
    quote = Quote.find(quote_id)
    view_quote_link(quote) + quote_amendment_link(quote) + quote_edit_link(quote) + quote_cancel_link(quote)
  end

  def view_quote_link(quote)
    link_to content_tag(:i, nil, class: 'icon-search'), quote, {:title => 'View', :class => 'btn action-link'}
  end

  def quote_amendment_link(quote)
    if can? :update, Quote && QuoteStatus.action_permitted?(:create_amendment, quote.status)
      link_to content_tag(:i, nil, class: 'icon-paste'), {:action => 'create_amendment', :quote_id => quote.id}, :title => 'Create Amendment', :class => 'btn action-link', 'rel' => 'tooltip', "data-placement" => "bottom", data: {confirm: "You are about to cancel this quote and create an ammended copy. Are you sure you want to do this?"}
    end
  end

  def quote_edit_link(quote)
    if (can? :update, Quote) && QuoteStatus.action_permitted?(:update, quote.status)
      link_to content_tag(:i, nil, class: 'icon-edit'), {controller: "quotes", action: "edit", id: quote.number}, {:title => 'Edit', :class => 'btn action-link'}
    end
  end

  def quote_cancel_link(quote)
    if can? :cancel, Quote
      unless quote.status == 'cancelled'
        link_to content_tag(:i, nil, class: 'icon-ban-circle'), {controller: "quotes", action: "cancel", quote_id: quote.number}, :class => 'btn action-link', :title => 'Cancel', 'rel' => 'tooltip', data: {confirm: "You are about to cancel quote number #{quote.number}. Are you sure you want to proceed?"}
      end
    end
  end

  def checkbox_option(options = {})
    (options and options['checked'] == 'checked') ? true : false
  end
  
  def options_for_selected_quote_tags(tag_ids)
    return "" unless tag_ids
    options = ""
    tag_ids.each do |tag_id|
      tag = ActsAsTaggableOn::Tag.find_by(id: tag_id)
      next unless tag
      options += "<option value='" + tag_id + "'>" + tag.name + "</option>"
    end
    options.html_safe
  end

end
