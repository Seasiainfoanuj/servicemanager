json.array!(@hire_agreements) do |hire_agreement|
  json.id "hi-" + hire_agreement.id.to_s
  json.uid "#" + hire_agreement.uid
  json.user hire_agreement.customer.company_name
  json.vehicle_id hire_agreement.vehicle_id
  json.vehicle_ref hire_agreement.vehicle.ref_name
  json.event_type "hire_agreement_" + hire_agreement.status.parameterize(sep = '_')
  json.status hire_status_label(hire_agreement.status)
  json.text "#" + hire_agreement.uid + " - Hire Agreement - " + hire_agreement.status.titleize + " - " + hire_agreement.customer.company_name_short
  case hire_agreement.status
    when 'cancelled'
      json.color "#e63a3a"
    else
      json.color "#51a541"
  end
  json.start_date hire_agreement.pickup_datetime
  json.end_date hire_agreement.return_datetime
  json.url hire_agreement_url(hire_agreement)
end
