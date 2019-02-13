class HireAddonPresenter < BasePresenter
  delegate :link_to, to: :@view

  def initialize(model, view)
    super
  end

  def options_for_addon_types
    HireAddon::ADDON_TYPES
  end

  def options_for_billing_frequencies
    HireAddon::BILLING_FREQUENCIES.collect { |bf| [bf.titleize, bf] }
  end

  def hire_price_display
    return "" unless hire_price_cents
    h.number_to_currency((hire_price_cents / 100), precision: 2, separator: '.', unit: '$') 
  end

end  
