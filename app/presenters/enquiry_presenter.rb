class EnquiryPresenter < BasePresenter
  delegate :can?, :link_to, to: :@view
  attr_accessor :hire, :company_address

  def initialize(model, view)
    super
    @enquiry = model
    @hire = model.hire_enquiry
    @company_address = model.user.representing_company.addresses.first if model.user && model.user.representing_company
  end

  def options_for_enquiry_types
    EnquiryType.all.map { |type| [type.name, type.id]}
  end

  def options_for_statuses
    Enquiry::STATUSES.map { |status| [status.titleize, status] }
  end

  def options_for_duration_units
    HireEnquiry::DURATION_UNITS.map { |unit| [unit.titleize, unit] }
  end

  def selected_customer
    if user.present?  
      @enquiry.user.id
    end
  end
  
  def user_id
    user.id if user
  end

  def transmission_preferences
    HireEnquiry::TRANSMISSION_PREFERENCES
  end

  def customer_name
    if user.present?
      user.name
    end
  end

    

  def customer_email
   if user.present?
      user.email
   end 
  end

  def customer_phone
    if user.present?
      phones = []
      phones << user.mobile if user.mobile.present?
      phones << user.phone if user.phone.present?
      phones.join(', ')
    end
  end

  def customer_company_name
    if user.present?
      user.representing_company.name if user.representing_company
    end 
  end

  def customer_job_title
    if user.present?
      user.job_title
    end 
  end

  def create_quote_link
    if (can? :create, Quote) and user.present?
      link_to "Create Quote", h.new_quote_path(customer: @enquiry.user, enquiry: @enquiry.id), :class => "btn btn-satgreen" 
    end  
  end

  # def create_hire_quote_link
  #   if (can? :create, HireQuote) and user.present?
  #     link_to "Create Hire Quote", { controller: "hire_quotes", action: "hire_quote_from_enquiry", enquiry_id: @enquiry.uid }, :class => "btn btn-satgreen"
  #   end
  # end


  def create_from_master_quote_link
    if (can? :create, Quote) and user.present?
      link_to "Master Quotes", { controller: "master_quotes", action: "index" }, :class => "btn btn-satgreen" 
    end  
  end

  def create_from_master_quote_international_link
    if (can? :create, Quote) and user.present?
      link_to "Master Quotes International", { controller: "master_quotes_internationals", action: "index" }, :class => "btn btn-orange" 
    end  
  end

  def hire_start_date
    if @hire and @hire.hire_start_date
      h.display_date(@hire.hire_start_date)
    end
  end
 
  

  def hire_period
    if @hire and @hire.units > 0
      period = "#{@hire.units} #{@hire.duration_unit.titleize}"
      period += " - until #{h.display_date(@hire.hire_start_date + @hire.units.send(@hire.duration_unit))}"
      period += " or later" if @hire.ongoing_contract
      period
    else
      "Not specified"  
    end  
  end

  def number_of_vehicles
    @hire.number_of_vehicles if @hire
  end

  def transmission_preference
    @hire.transmission_preference if @hire
  end

  def minimum_seats
    @hire.minimum_seats if @hire
  end

  def ongoing_contract
    return unless @hire
    @hire.ongoing_contract ? "YES" : "NO"
  end

  def special_requirements
    @hire.special_requirements if @hire
  end

  def delivery
    if @hire and @hire.delivery_required
      "Vehicle must be delivered at #{@hire.delivery_location}"
    else
      "Vehicle delivery is not required"  
    end
  end

end