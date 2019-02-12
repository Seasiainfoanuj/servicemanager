module VehiclesHelper

  def vehicle_status_label(status)
    case status
    when 'available'
      "<span class='label label-success'>#{status.humanize.capitalize}</span>".html_safe
    when 'on_offer'
      "<span class='label label-warning'>#{status.humanize.capitalize}</span>".html_safe
    when 'sold'
      "<span class='label label-info'>#{status.humanize.capitalize}</span>".html_safe
    else
      "<span class='label label-lightgrey'>unknown</span>".html_safe
    end
  end

  def vehicle_event_types
    return "" unless NotificationType.exists?(resource_name: 'Vehicle')
    types = NotificationType.all.select { |type| type.resource_name == 'Vehicle' }
    types.collect { |type| type.event_name }.join(", ")
  end

  def options_for_vehicles_and_models
    vehicles = Vehicle.includes(model: :make)
    vehicles.collect { |veh| ["Rego: #{veh.rego_number} | VIN: #{veh.vin_number} | Model: #{veh.model_year} #{veh.model.make.name} #{veh.model.name}", veh.id ] }
  end

end
