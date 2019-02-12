class UsersController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_user, only: [:show, :edit, :update, :show_company_profile, :edit_company_profile, 
    :add_contact_role, :remove_contact_role, :update_company_profile, :destroy]

  add_crumb('People') { |instance| instance.send :users_path }
      
     
  def index
    session['last_request'] = '/users'
   
    @users = User.all
    add_crumb 'All Users'
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
      format.csv do
        @users = []
        User.includes(:representing_company).map do |user|
          if user.representing_company.present?
            @users << [user.id, user.first_name, user.last_name, user.email, user.phone, user.mobile, user.company, user.representing_company.name]
          else
            @users << [user.id, user.first_name, user.last_name, user.email, user.phone, user.mobile, user.company, '---']
          end  
        end
        render csv: @users  
      end  
    end
  end
   
  def show
    redirect_to :back if @user.nil? 
    add_crumb @user.name, @users
    if current_user.admin?
      @activities = PublicActivity::Activity.order("created_at desc")
                      .where(:owner_type => 'User', :owner_id => @user.id)
                      .where("created_at > ?", Date.today - 6.months)
    end  
  end

  def new
    @user = User.new
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    @user.roles = []
    add_crumb 'New User'
  end

  def admin
    @user = User.new(:roles => :admin)
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    add_crumb 'New Administrator'
  end

  def administrators
    session['last_request'] = '/administrators'
    @users = User.where('roles_mask = 1')
    add_crumb "Administrators"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
  end

  def supplier
    @user = User.new(:roles => :supplier)
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    add_crumb 'New Supplier'
  end

  def suppliers
    session['last_request'] = '/suppliers'
    @users = User.supplier
    add_crumb "Suppliers"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
  end

  def service_provider
    @user = User.new(:roles => :service_provider)
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    add_crumb 'New Service Provider'
  end

  def service_providers
    session['last_request'] = '/service_providers'
    @users = User.service_provider
    add_crumb "Service Providers"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
  end

  def customer
    @user = User.new(:roles => :customer)
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    add_crumb 'New Customer'
  end

  def customers
    session['last_request'] = '/customers'
    @users = User.customer
    add_crumb "Customers"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
  end

  def quote_customer
    @user = User.new(:roles => :quote_customer)
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    add_crumb 'New Customer'
  end

  def quote_customers
    session['last_request'] = '/quote_customers'
    @users = User.quote_customer
    add_crumb "Quote Customers"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
  end

  def employee
    @user = User.new(:roles => :employee)
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    add_crumb 'New Customer'
  end

  def employees
    session['last_request'] = '/employees'
    @users = User.employee
    add_crumb "Employee"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
  end
  
   def masteradmins
    session['last_request'] = '/masteradmins'
    @users = User.masteradmin
    add_crumb "Employee"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
   end

   def superadmins
    session['last_request'] = '/superadmins'
    @users = User.superadmin
    add_crumb "Employee"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
   end
   
   def dealer
    @user = User.new(:roles => :dealer)
    [Address::POSTAL, Address::PHYSICAL, Address::BILLING, Address::DELIVERY].each do |addr_type|
      @user.addresses.build(address_type: addr_type)
    end
    add_crumb 'New Dealer'
   end

   def dealers
    session['last_request'] = '/dealers'
    @users = User.dealer
    add_crumb "Dealer"
    respond_to  do |format|
      format.html
      format.json { render json: UsersDatatable.new(view_context, current_user, @users) }
    end
   end
   

  def create
    @user = User.new(user_params_formatted)
    @user.build_client(client_type: "person")
    if params['new_company'].present?
      define_company_for_user
    end  
    if @user.password.blank?
      pass = Devise.friendly_token.first(8)
      @user.password = pass
      @user.password_confirmation = pass
    end
    if @user.save
      perform_redirect
    else
      flash[:error] = "User create failed."
      render('new')
    end
  end

  def edit
    @user.addresses.build(address_type: Address::POSTAL) unless @user.postal_address
    @user.addresses.build(address_type: Address::PHYSICAL) unless @user.physical_address
    @user.addresses.build(address_type: Address::BILLING) unless @user.billing_address
    @user.addresses.build(address_type: Address::DELIVERY) unless @user.delivery_address
    @user.build_licence unless @user.licence
    add_crumb @user.name, user_path(@user)
    add_crumb 'Edit Profile'
  end

  def add_contact_role
    contact_role_id = params.require(:contact_role_type_id)
    role_type = ContactRoleType.find_by(id: contact_role_id)
    @user.contact_role_types << role_type
    flash[:success] = "Contact role has been added to user"
    redirect_to(:action => 'show_company_profile')
  rescue  
    flash[:error] = "Contact role has already been added to user"
    redirect_to(:action => 'show_company_profile')
  end

  def remove_contact_role
    contact_role_id = params.require(:contact_role_type_id)
    role_type = ContactRoleType.find_by(id: contact_role_id)
    @user.contact_role_types.delete(role_type)
    flash[:success] = "Contact role has been removed from user"
    redirect_to(:action => 'show_company_profile')
  rescue  
    flash[:error] = "Contact does not have this contact role"
    redirect_to(:action => 'show_company_profile')
  end

  def show_company_profile
    redirect_to :back if @user.nil? 
    add_crumb @user.name, @users
    add_crumb 'Company Profile'
  end

  def edit_company_profile
  end

  def update_company_profile
    # "user"=>{"representing_company_id"=>"2227", "job_title"=>"Coordinator Outdoor Education ", 
    # "receive_emails"=>"1"}, "commit"=>"Update", "id"=>"1025"}
    if @user.update_attributes(user_params)
      flash[:success] = "Company profile for user has been updated."
      redirect_to(:action => 'show_company_profile')
    else
      flash[:error] = "Company profile for user could not be updated."
      render('edit')
    end
  end

  
  def update
    if @user.update_attributes(user_params_formatted)
      sign_in(current_user, :bypass => true)
      flash[:success] = "User updated."
      if session['last_request'].present?
        #redirect_to session['last_request']
        if (@user.has_role? :admin) && (! @user.has_role? :superadmin) && (!@user.has_role? :masteradmin, :dealer)
          redirect_to(:action => 'administrators')
        elsif (@user.has_role? :admin) && ( @user.has_role? :superadmin) && (!@user.has_role? :masteradmin)
          redirect_to(:action => 'superadmins')  
        elsif (@user.has_role? :admin) && (! @user.has_role? :superadmin) && (@user.has_role? :masteradmin)
          redirect_to(:action => 'masteradmins')  
        elsif @user.has_role? :supplier
          redirect_to(:action => 'suppliers')
        elsif @user.has_role? :service_provider
          redirect_to(:action => 'service_providers')
        elsif @user.has_role? :customer
          redirect_to(:action => 'customers')
        elsif @user.has_role? :quote_customer
          redirect_to(:action => 'quote_customers')
        elsif @user.has_role? :dealer
          redirect_to(:action => 'dealers')
        else
          redirect_to(:action => 'edit')
        end
      end 
    else
      flash.now["error"] = "Failed to update user"
      render('edit')
    end
  end

    def destroy
      if (current_user.has_role? :masteradmin) || (current_user.has_role? :superadmin)
        if @user.admin?
          @user.soft_delete
        else
          @user.destroy
        end
        flash[:success] = "User has been deleted."
      else
        flash[:success] = "You are not authorized to delete user"
      end 
      redirect_to session['last_request']
    end
 
  def can_delete_user?
    return false if @user.admin?
    return false if @user.supplied_stocks.any? || @user.stock_requests.any?
    return false if @user.supplied_vehicles.any? || @user.vehicles.any?
    return false if @user.vehicle_log_entries.any?
    return false if @user.workorders.any? || @user.customer_workorders.any? || @user.managed_workorders.any?
    return false if @user.hire_agreements.any? || @user.managed_hire_agreements.any?
    return false if @user.quotes.any? || @user.managed_quotes.any?
    return false if @user.enquiries.any?
    return false if @user.vehicle_contracts.any?
    return false if @user.managed_builds.any? || @user.build_orders.any? || @user.managed_build_orders.any?
    return false if @user.off_hire_jobs.any?
    return false if @user.job_subscribers.any?
    true
  end

private

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def user_params_formatted
    new_params = user_params
    return new_params unless new_params["addresses_attributes"].present?
    new_params["addresses_attributes"].each do |addr|
      addr.last["address_type"] = addr.last["address_type"].to_i
    end
    new_params
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :dob_field,
      :email,
      :phone,
      :fax,
      :mobile,
      :website,
      :company,
      :job_title,
      :avatar,
      :password,
      :password_confirmation,
      :remember_me,
      :roles_mask,
      :representing_company_id,
      :employer_id,
      :check_user,
      :receive_emails,
      roles: [:admin, :supplier, :customer, :contact,:employee,:masteradmin,:superadmin,:dealer],
      addresses_attributes: [:id, :address_type, :line_1, :line_2, :suburb, :state, :postcode, :country],
      licence_attributes: [:id, :number, :state_of_issue, :expiry_date_field, :upload]
    )
  end
 
  def perform_redirect
    user_roles = @user.roles.map { |role| role.to_s.humanize }.flatten.join(', ')
    flash[:success] = "User with roles #{user_roles} has been created."
    role = @user.roles.first
    case role
    when (:admin) && (!:superadmin ) &&(!:dealer)
      redirect_to(:action => 'administrators') 
    when (:admin) && (:superadmin )
      redirect_to(:action => 'superadmins')
   when :supplier
      redirect_to(:action => 'suppliers')
    when :service_provider
      redirect_to(:action => 'service_providers')
    when :customer
      redirect_to(:action => 'customers')
    when :employee
      redirect_to(:action => 'employees')
    when :dealer
      redirect_to(:action => 'dealers')
    when :quote_customer
      if params[:quote_id]
        redirect_to(:controller => 'quotes', :action => 'edit', :quote_id => params[:quote_id], :customer_id => @user.id)
      else
        redirect_to(:controller => 'quotes', :action => 'new', :customer => @user.id)
      end
    else
      flash[:success] = "User created."
      redirect_to(:action => 'index')
    end
  end

  def define_company_for_user
    company_name = params['new_company']
    abn = params['company_abn']
    trading_name = params['trading_name'].present? ? params['trading_name'] : params['new_company']
    website = params['company_website']
    if Company.exists?(name: company_name)
      company = Company.find_by(name: company_name)
    else
      company = Company.create(name: company_name, trading_name: trading_name, 
        abn: abn, website: website, client_attributes: {client_type: "company"})
    end
    @user.representing_company_id = company.id
  end
end

