class QuotePresenter < BasePresenter

  attr_reader :dealer, :customer_postal_address

  def initialize(model, view)
    super
    @quote = model
    @dealer = model.invoice_company
    @customer = model.customer
    @customer_postal_address = (@customer.postal_address || nil) if @customer
  end

  def show_cost_to_admin?(show_costs)
    h.current_user.has_role?(:admin) && show_costs == "true"
  end

  def hide_cost_from_admin?(show_costs)
    h.current_user.has_role?(:admin) && !show_costs
  end

  def show_linked_order?
    sales_order.present?
  end

  def show_create_sales_order_link?
    status == "accepted" && h.can?(:create, SalesOrder)
  end

  def show_status_label?
    h.current_user.admin? || status == "changes requested" || status == "accepted"
  end

  def dealer_name
    @dealer.name
  end

  def dealer_logo(size)
    @dealer.logo.url(size)
  end

  def dealer_address_line_1
    @dealer.address_line_1
  end

  def manager_name
    manager.name
  end

  def dealer_address_line_2
    unless @dealer.address_line_2.blank?
      "#{@dealer.address_line_2} <br>".html_safe 
    end
  end

  def dealer_address_remainder
    "#{@dealer.suburb}, #{@dealer.state} #{@dealer.postcode}"
  end

  def dealer_suburb
    @dealer.suburb
  end

  def dealer_state
    @dealer.state
  end

  def dealer_postcode
    @dealer.postcode
  end

  def dealer_country
    @dealer.country
  end

  def dealer_phone
    unless @dealer.phone.blank?
      "Phone: #{@dealer.phone} <br>".html_safe 
    end
  end

  def dealer_fax
    unless @dealer.fax.blank?
      "Fax: #{@dealer.fax} <br>".html_safe 
    end
  end

  def customer_name
    @customer.name
  end

  def customer_email
    @customer.email
  end

  def customer_authentication_token
    @customer.authentication_token
  end

  def customer_company_name
    if @customer.representing_company.present?
      @customer.representing_company.name 
    end
  end

  def customer_postal_address
    @customer.postal_address
  end

  def customer_postal_address_line_1
    @customer_postal_address.line_1 if @customer_postal_address
  end

  def customer_postal_address_line_2
    if @customer_postal_address.present? && @customer_postal_address.line_2.present?
      "#{@customer_postal_address.line_2} <br>".html_safe 
    end
  end

  def customer_postal_address_suburb
    if @customer_postal_address.present?
      @customer_postal_address.suburb
    end
  end

  def customer_postal_address_postcode
    if @customer_postal_address.present?
      @customer_postal_address.postcode
    end
  end

  def customer_postal_address_state
    if @customer_postal_address.present?
      @customer_postal_address.state
    end
  end

  def customer_postal_address_country
    if @customer_postal_address.present? && @customer_postal_address.country.present?
      "<br> #{@customer_postal_address.country}".html_safe
    end
  end

  def customer_phone
    if @customer.phone.present?
      "#{@customer.phone} <br>".html_safe 
    end
  end

  def customer_mobile
    if @customer.mobile.present?
      "#{@customer.mobile} <br>".html_safe 
    end
  end

  def customer_website
    if @customer.website.present?
      "Website: #{@customer.website} <br>".html_safe 
    end
  end

  def selected_customer
    @customer.present? ? @customer.id : ""
  end

  def quote_contract_path
    "/vehicle_contracts/#{@quote.vehicle_contract.uid}"
  end

end
