json.array!(@build_orders) do |build_order|
  json.id "bo-" + build_order.id.to_s
  json.uid build_order.uid
  json.user build_order.service_provider.company_name
  json.vehicle_id build_order.build.vehicle_id
  json.vehicle_ref build_order.build.vehicle.ref_name
  json.event_type "build_order_" + build_order.status.parameterize(sep = '_')
  json.status build_order_status_label(build_order.status)
  json.text "#" + build_order.uid + " - " + build_order.name
  case build_order.status
    when 'cancelled'
      json.color "#e63a3a"
    else
      json.color "#000000"
  end
  json.start_date build_order.sched_datetime
  json.end_date build_order.etc_datetime
  json.url build_order_url(build_order)
end
