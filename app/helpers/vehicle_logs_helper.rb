module VehicleLogsHelper
  def log_flagged_icon(vehicle_log)
    if vehicle_log.flagged == true
      content_tag(:i, nil, class: 'glyphicon-flag')
    else
      "" #return empty string
    end
  end

  def flagged_vehicle_log_entries_count
    VehicleLog.where(flagged: true).count
  end

  def flagged_vehicle_log_entries_label(flagged_vehicle_log_entries_count)
    content_tag(:span, flagged_vehicle_log_entries_count, class: 'label label-orange') if flagged_vehicle_log_entries_count > 0
  end

  def flagged_vehicle_log_entries_label_small(flagged_vehicle_log_entries_count)
    content_tag(:span, "#{flagged_vehicle_log_entries_count} <i class='icon-flag'></i>".html_safe, class: 'label label-orange label-small', style: "margin-left: 3px;") if flagged_vehicle_log_entries_count > 0
  end
end
