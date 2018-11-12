json.array!(@workorders) do |workorder|
  json.id "wo-" + workorder.id.to_s
  json.uid workorder.uid
  json.vehicle_id workorder.vehicle_id
  json.vehicle_ref workorder.vehicle.ref_name
  json.event_type "workorder_" + workorder.type.name.parameterize(sep = '_')
  json.status workorder_status_label(workorder.status)
  json.text "#" + workorder.uid + " - " + workorder.type.name
  json.color workorder.type.label_color
  json.start_date workorder.sched_datetime
  json.end_date workorder.etc_datetime
  json.url workorder_url(workorder)
end
