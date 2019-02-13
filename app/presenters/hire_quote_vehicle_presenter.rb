class HireQuoteVehiclePresenter < BasePresenter
  delegate :link_to, to: :@view

  def initialize(model, view)
    super
    @vehicle_model = model.vehicle_model
    @quote = model.hire_quote
    @hire_enquiry = @quote.enquiry ? @quote.enquiry.hire_enquiry : nil
  end

  def options_for_vehicle_models
    VehicleModel.includes(:make).collect { |model| ["#{model.make.name} #{model.name}", model.id] }
  end

  def vehicle_model_name
    @vehicle_model.name
  end

  def pickup_location_details
    pickup_location.present? ? pickup_location : "Not required"
  end

  def dropoff_location_details
    dropoff_location.present? ? dropoff_location : "Not required"
  end

  def delivery_required_details
    delivery_required ? 'Yes' : 'No'
  end

  def demobilisation_required_details
    demobilisation_required ? 'Yes' : 'No'
  end

  def ongoing_contract_details
    ongoing_contract ? "Yes" : "No"
  end

  def show_enquiry_details?
    @quote.status == "draft" && @quote.enquiry.present?
  end

  def enquiry_transmission
    if @hire_enquiry
      @hire_enquiry.transmission_preference.titleize
    end
  end

  def enquiry_reference
    @quote.enquiry.uid if @quote.enquiry
  end

  def enquiry_seat_capacity
    if @hire_enquiry
      @hire_enquiry.minimum_seats
    end
  end

  def enquiry_number_of_vehicles
    if @hire_enquiry
      @hire_enquiry.number_of_vehicles
    end
  end

  def enquiry_details
    @quote.enquiry.details if @quote.enquiry
  end

  def enquiry_special_requirements
    if @hire_enquiry
      @hire_enquiry.special_requirements
    end
  end

  def daily_rate_display
    if daily_rate_cents
      h.number_to_currency((daily_rate_cents.to_f / 100), precision: 2, separator: '.', unit: '$') 
    end
  end

  def mobilisation_details
    if delivery_required and demobilisation_required
      "Requesting delivery and demobilisation"
    elsif delivery_required
      "Delivery requested"
    elsif demobilisation_required
      "Demobilisation requested"
    else
      "Not requested"
    end
  end

  def quote_reference
    @quote.reference
  end

  def customer_description
    @quote.customer.name
  end

  def product_description
    "#{@vehicle_model.name} (#{@vehicle_model.number_of_seats} seats)"
  end

end  