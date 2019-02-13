module HireAddonsHelper
  def addon_name_label(addon)
    name = "#{addon.addon_type} #{addon.hire_model_name}"
    content_tag(:span, name, class: 'label label-blue').html_safe
  end
end
