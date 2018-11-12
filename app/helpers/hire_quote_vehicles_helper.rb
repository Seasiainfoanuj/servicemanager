module HireQuoteVehiclesHelper

  def hire_quote_vehicle_name_label(hire_quote_vehicle)
    content_tag(:span, hire_quote_vehicle.name, class: 'header-label label-blue')
  end

end