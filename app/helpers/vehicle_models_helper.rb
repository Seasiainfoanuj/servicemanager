module VehicleModelsHelper

  def hire_product_type_list(vehicle_model)
    return "NONE" if vehicle_model.hire_product_types.none?
    vehicle_model.hire_product_types.map(&:name).join(', ')
  end

  def hire_addon_list(vehicle_model)
    return "NONE" if vehicle_model.hire_addons.none?
    vehicle_model.hire_addons.map(&:name).join(', ')
  end

  def vehicle_model_name_label(vehicle_model)
    content_tag(:span, vehicle_model.name, class: 'label label-orange').html_safe
  end

end
