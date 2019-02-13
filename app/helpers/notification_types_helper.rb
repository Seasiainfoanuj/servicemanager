module NotificationTypesHelper

  def notification_type_label(ntype, options = {})
    if options[:content] == :event_full_name
      "<span class='label' style='background-color: #{ntype.label_color.downcase}'>#{ntype.event_full_name}</span>".html_safe
    else
      "<span class='label' style='background-color: #{ntype.label_color.downcase}'>#{ntype.event_name}</span>".html_safe
    end  
  end

  def notification_type_formatted_text(colour)
    "<span class='label' style='background-color: #{colour.downcase}; padding: 4px'>#{colour}</span>".html_safe
  end

  def array_from_periods(periods)
    list = periods.strip_tags.split(', ')
    new_list = []
    list.each { |item| new_list << item.strip.to_i }
    new_list.sort.reverse
  end

  def options_for_notification_types(resource_name)
    types = NotificationType.where(resource_name: resource_name)
    if types.any?
      types.collect { |type| ["#{type.resource_name} / #{type.event_name}", type.id]}
    end
  end

  def options_for_resource_name
    NotificationType::REGISTERED_RESOURCE_NAMES.collect { |type| [type, type] }
  end
end
