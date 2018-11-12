json.array!(@build_orders) do |build_order|
  json.title "#" + build_order.uid + " - " + build_order.name
  json.start build_order.sched_time
  json.end build_order.etc
  json.allDay false
  json.resource build_order.build.vehicle.id
  case build_order.status
    when 'pending'
      json.color "#000000"
    when 'confirmed'
      json.color "#000000"
    when 'complete'
      json.color "#56af45"
    when 'cancelled'
      json.color "#e63a3a"
  end
  json.className "fc-event-build-order"
  json.url build_order_url(build_order)
  json.popover_title build_order.name + " #" + build_order.uid
  json.popover_content "Scheduled Start " + build_order.sched_time_field + " - " + build_order.service_provider.company_name_short + " - Estimated to be complete at " + build_order.etc_time_field + " " + build_order.etc_date_field 
end