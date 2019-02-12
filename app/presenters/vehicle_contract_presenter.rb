class VehicleContractPresenter
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  attr_reader :vehicle_contract, :customer, :vehicle, :quote, :dealer, :manager,
              :customer_company

  def initialize(vehicle_contract)
    @vehicle_contract = vehicle_contract
    if @vehicle_contract.persisted?
      @quote = @vehicle_contract.quote
    else
      @quote = Quote.find(vehicle_contract.quote_id)
    end
    @dealer = @vehicle_contract.invoice_company
    @vehicle = @vehicle_contract.vehicle
    @stock = @vehicle_contract.allocated_stock
    @manager = @vehicle_contract.manager
    @customer = @vehicle_contract.customer
    @customer_company = @customer.representing_company
    @subtotals = @quote.subtotals_per_quote_item_type
  end

  # ------------------------------------------------------
  # DEALER DETAILS
  # ------------------------------------------------------
  def manager_name
    @manager.name
  end

  def dealer_suburb_line
    "#{@dealer.suburb} #{@dealer.state}, #{@dealer.postcode}"
  end

  def dealer_logo(format = nil)
    size = format || :large
    @dealer.logo.present? ? @dealer.logo.url(size) : nil
  end

  def manager_names
    User.admin.collect { |user| ["#{user.first_name} #{user.last_name}", user.id]}
  end

  def selected_manager
    @manager.present? ? @manager.id : ""
  end

  # ------------------------------------------------------
  # CUSTOMER DETAILS
  # ------------------------------------------------------
  def customer_name
    @customer.name
  end

  def customer_company_name
    @customer_company.name if @customer_company
  end

  def customer_abn
    if @customer_company.present? && @customer_company.abn.present?
      @customer_company.abn
    else
      @customer.abn
    end
  end

  def customer_address_lines
    addr_lines = []
    address = customer_preferred_contract_address
    if address
      addr_lines << address.line_1
      addr_lines << address.line_2 if address.line_2.present?
      addr_lines << address.suburb if address.suburb.present?
      if address.state.present? && address.postcode.present?
        addr_lines << "#{address.state}, #{address.postcode}"
      end
      addr_lines << address.country unless address.country == 'Australia'
    end
    addr_lines
  end

  def customer_preferred_contract_address
    preferred_address = nil
    if @customer_company
      preferred_address = @customer_company.preferred_address({usage: :vehicle_contract})
    end
    unless preferred_address
      preferred_address = @customer.preferred_address({usage: :vehicle_contract, role: :customer})
    end
    preferred_address        
  end

  def options_for_customers
    customers = User.customer.includes(:representing_company)
    quote_customers = User.quote_customer.includes(:representing_company)
    users = customers + quote_customers
    users.collect do |user| 
      if user.representing_company
        ["#{user.representing_company.name} - #{user.first_name} #{user.last_name} - #{user.email}", user.id]
      else
        ["#{user.first_name} #{user.last_name} - #{user.email}", user.id]
      end
    end
  end

  def selected_customer
    @customer.present? ? @customer.id : ""
  end

  # ------------------------------------------------------
  # QUOTATION DETAILS
  # ------------------------------------------------------
  def quote_number
    @quote.number
  end

  def quote_date
    display_date(@quote.date)
  end

  def quote_item_types
    QuoteItemType.all.collect { |type| type.name }
  end

  def quote_items_subtotal_by(quote_item_type_name)
    number_to_currency(quote.subtotal_by_type(quote_item_type_name), precision: 2) 
  end

  # ------------------------------------------------------
  # ALLOCATED STOCK DETAILS
  # ------------------------------------------------------
  def selected_stock
    @stock.present? ? @stock.id : ""
  end

  def stock_and_models
    all_stock = Stock.includes(model: :make)
    all_stock.collect { |stock| ["Stock#: #{stock.stock_number} | VIN: #{stock.vin_number} | Model: #{stock.model.make.name} #{stock.model.name}", stock.id ] }
  end

  # ------------------------------------------------------
  # VEHICLE DETAILS
  # ------------------------------------------------------
  def vehicle_details_available?
    @vehicle.present?
  end

  def vehicle_name
    if @vehicle.present?
      @vehicle.name
    else
     'unavailable'
    end
  end

  def vehicle_model
    if @vehicle.present?
      @vehicle.model.full_name
    else
     'unavailable'
    end
  end  

  def vehicle_vin_number
    if @vehicle.present?
      @vehicle.vin_number
    else
     'unavailable'
    end
  end

  def vehicle_engine_number
    if @vehicle.present?
      @vehicle.engine_number
    else
     'unavailable'
    end
  end

  def vehicle_body_type
    @vehicle.body_type if @vehicle.present?
  end

  def vehicle_colour
    @vehicle.colour if @vehicle.present?
  end

  def vehicle_transmission
    if @vehicle.present?
      @vehicle.transmission
    else
     'unavailable'
    end
  end

  def vehicle_build_date
    if @vehicle && @vehicle.build_date
      display_date(@vehicle.build_date)
    else
      'TO BE ANNOUNCED'
    end
  end

  def rego_number
    @vehicle.rego_number if @vehicle.present?
  end

  def engine_type
    @vehicle.engine_type if @vehicle.present?
  end

  def selected_vehicle
    @vehicle.present? ? @vehicle.id : ""
  end

  def vehicles_and_models
    vehicles = Vehicle.includes(model: :make)
    vehicles.collect { |veh| ["Rego: #{veh.rego_number} | VIN: #{veh.vin_number} | Model: #{veh.model_year} #{veh.model.make.name} #{veh.model.name}", veh.id ] }
  end

  # ------------------------------------------------------
  # VEHICLE CONTRACT DETAILS
  # ------------------------------------------------------
  def display_status
    @vehicle_contract.present? ? @vehicle_contract.status_name : ""
  end

  def status_date
    # display_date(@vehicle_contract.status_date)
  end

  def deposit_value
    @vehicle_contract.deposit_received.to_f
  end

  def deposit_received
    number_to_currency(@vehicle_contract.deposit_received, precision: 2)
  end

  def deposit_received_date
    display_date(@vehicle_contract.deposit_received_date)
  end

  def special_conditions
    if @vehicle_contract.special_conditions.present?
      @vehicle_contract.special_conditions.html_safe 
    else
      "No special conditions are provided"
    end  
  end

  def invoice_company_names
    InvoiceCompany.all.collect { |cpy| [cpy.name, cpy.id] }
  end

  def selected_invoice_company
    @dealer.present? ? @dealer.id : ""
  end

  def customer_item_list
    @customer_item_list ||= quote.customer_item_list
  end

  # ------------------------------------------------------
  # VEHICLE CONTRACT FINANCIAL DETAILS
  # ------------------------------------------------------
  def visible_items
    customer_item_list[:visible_items] || []
  end

  def hidden_items
    customer_item_list[:hidden_items] || []
  end

  def accessories_total
    number_to_currency(@subtotals['Accessory'], precision: 2)
  end

  def add_on_total
    number_to_currency(@subtotals['Add-on'], precision: 2)
  end

  def accessories_add_ons_total
    number_to_currency((@subtotals['Accessory'].to_f + @subtotals['Add-on'].to_f), precision: 2)
  end

  def packaged_value
    @subtotals['Package'].to_f
  end

  def packaged_items_total
    number_to_currency(packaged_value, precision: 2)
  end

  def registration_total
    number_to_currency(@subtotals['Vehicle Registration'], precision: 2)
  end

  def ctp_insurance_total
    number_to_currency(@subtotals['CTP Insurance'], precision: 2)
  end

  def stamp_duty_total
    number_to_currency(@subtotals['Stamp duty'], precision: 2)
  end

  def all_fees_value
    return @all_fees_value if @all_fees_value
    stamp_duty = @subtotals['Stamp duty'] || 0
    rego = @subtotals['Vehicle Registration'] || 0
    ctp = @subtotals['CTP Insurance'] || 0
    @all_fees_value = stamp_duty.to_f + rego.to_f + ctp.to_f
  end

  def value_without_fees
    @value_without_fees ||= @quote.grand_total.to_f - all_fees_value - @quote.tax_total.to_f
  end

  def extras_only_value
    @extras_only_value ||= @quote.grand_total.to_f - vehicle_alone_value - packaged_value - all_fees_value - @quote.tax_total.to_f
  end

  def extras_only_total
    number_to_currency(extras_only_value, precision: 2)
  end

  def vehicle_alone_value
    return @vehicle_alone_value if  @vehicle_alone_value
    vehicle_price = @subtotals['Vehicle'] || 0
    body_price = @subtotals['Body'] || 0
    chassis_price = @subtotals['Chassis'] || 0
    @vehicle_alone_value = vehicle_price.to_f + body_price.to_f + chassis_price.to_f
  end

  def sale_price_vehicle_alone
    number_to_currency(vehicle_alone_value, precision: 2)
  end

  def sale_price_before_registration_value
    value_without_fees
  end

  def sale_price_before_registration
    number_to_currency(sale_price_before_registration_value, precision: 2)
  end

  def total_gst
    number_to_currency(@quote.tax_total.to_f, precision: 2)
  end

  def balance_due
    number_to_currency((@quote.grand_total.to_f - deposit_value), precision: 2)
  end

  def payable_value
    @quote.grand_total.to_f
  end

  def total_amount_payable
    number_to_currency(@quote.grand_total.to_f, precision: 2)
  end

end
