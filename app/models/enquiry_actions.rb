module EnquiryActions

  def user_from_enquiry
    user = User.find_by_email(@enquiry.email)
    return user if user.present?
    temp_pw = User.generate_password
    user = User.new(
      first_name: @enquiry.first_name,
      last_name: @enquiry.last_name,
      phone: @enquiry.phone,
      email: @enquiry.email,
      job_title: @enquiry.job_title,
      password: temp_pw,
      password_confirmation: temp_pw,
      roles: [:contact]
    )
    user.build_client(client_type: "person")
    user.save ? user : nil
  end

  def initialise_enquiry
    @enquiry = Enquiry.new(new_enquiry_params)
    @enquiry.seen = false
    @enquiry.status = 'new'
    @enquiry.origin = Enquiry::SERVICE_MANAGER
    
    @enquiry.user = user_from_enquiry
    assign_enquiry_company_to_user
    assign_enquiry_address_to_company if @enquiry.address

    if @enquiry.hire_enquiry?
      @enquiry.enquiry_type = EnquiryType.hire_enquiry
      @enquiry.invoice_company = InvoiceCompany.hire_company
    end
  end

  def assign_enquiry_company_to_user
    return unless @enquiry.company.present?
    company = Company.find_by(name: @enquiry.company)
    user = @enquiry.user
    if company.blank?
      company = create_company_from_enquiry 
    end
    if @enquiry.user.representing_company.nil?
      user.representing_company_id = company.id
      user.save!
    end 
  end  

  def assign_enquiry_address_to_company
    company = @enquiry.user.representing_company
    if company and company.addresses.none?
      company.addresses.build(address_type: Address::POSTAL, 
        line_1: @enquiry.address.line_1, line_2: @enquiry.address.line_2, suburb: @enquiry.address.suburb, 
        state: @enquiry.address.state, postcode: @enquiry.address.postcode, country: @enquiry.address.country)
      company.save
    end  
  end

  def create_company_from_enquiry
    company = Company.new(name: @enquiry.company)
    company.build_client(client_type: "company")
    company.save!
    company
  end

  def record_assign_activity type = :assigned
    @enquiry.create_activity type, owner: current_user, recipient: @enquiry.manager
  end

end
