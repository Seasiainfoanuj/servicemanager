class VehicleModelPresenter < BasePresenter
  delegate :link_to, to: :@view

  def initialize(model, view)
    super
    @addon_ids = hire_addons.map(&:id)
    @product_type_ids = hire_product_types.map(&:id)
  end

  def vehicle_make_name
    vehicle_make.name
  end

  def includes_addon?(addon)
    @addon_ids.include?(addon.id)
  end

  def includes_product_type?(product_type)
    @product_type_ids.include?(product_type.id)
  end

  def daily_rate_display
    h.number_to_currency((daily_rate_cents / 100), precision: 2, separator: '.', unit: '$') 
  end

  def display_tags
    tags ? tags.titleize : ""
  end

end