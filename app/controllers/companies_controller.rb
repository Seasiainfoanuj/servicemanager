class CompaniesController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_company, only: [:edit, :update, :destroy, :add_contact]

  add_crumb('Companies') { |instance| instance.send :companies_path }

  def index
    session['last_request'] = '/companies'
    @companies = Company.all
    add_crumb 'All Companies'
    respond_to  do |format|
      format.html
      format.json { render json: CompaniesDatatable.new(view_context, current_user, @companies) }
      format.csv do
        @companies = []
        Company.all.each.map do |cpy|
          @companies << [cpy.id, cpy.name]
        end
        render csv: @companies  
      end
    end
  end

  def show
    @company = Company.includes(:client, :addresses, :contacts).where(id: params[:id]).first
    redirect_to :back if @company.nil? 
    add_crumb @company.name, @companies
  end

  def new
    @company = Company.new
    add_crumb 'New Company'
    @company.addresses.build(address_type: Address::POSTAL)
    @company.addresses.build(address_type: Address::PHYSICAL)
    @company.addresses.build(address_type: Address::BILLING)
  end

  def create
    @company = Company.new(company_params_formatted)
    @company.build_client(client_type: "company")
    if @company.save
      flash[:success] = "Company, #{@company.name}, has been added."
      redirect_to companies_path
    else
      flash[:error] = "Failed to create company."
      render :new
    end
  end

  def edit
    add_crumb @company.name, company_path(@company)
    add_crumb 'Edit Company'
    if @company.postal_address.nil?
      @company.addresses.build(address_type: Address::POSTAL)
    end
    if @company.physical_address.nil?
      @company.addresses.build(address_type: Address::PHYSICAL)
    end
    if @company.billing_address.nil?
      @company.addresses.build(address_type: Address::BILLING)
    end
  end

  def update
    if @company.update_attributes(company_params)
      flash[:success] = "Company, #{@company.name}, has been updated."
      redirect_to(:action => 'show')
    else
      flash[:error] = "Failed to update company."
      render :edit
    end
  end

  def destroy
    if @company.can_be_deleted?
      @company.destroy 
      flash[:success] = "Company deleted."
    else
      flash[:error] = "Cannot delete company, #{@company.name}. It still has contacts."
    end
    redirect_to(:action => 'index')
  end

  def add_contact
    user_id = params[:user_id]
    unless user_id and User.exists?(id: user_id)
      flash[:error] = "No user has been selected, or user is invalid"
      redirect_to(:action => 'show') and return
    end
    user = User.find(user_id)
    if user.employee?
      flash[:error] = "A staff member may not be selected"
      redirect_to(:action => 'show') and return
    end  
    if @company.contacts.include?(user)
      flash[:error] = "#{user.first_name} #{user.last_name} is already a contact for #{@company.name}"
      redirect_to(:action => 'show') and return
    end  
    if user.representing_company.present?
      flash[:error] = "#{user.first_name} #{user.last_name} is a contact for #{user.representing_company.name}. \
                       First remove the contact from this company before proceeding."
      redirect_to(:action => 'show') and return
    end  
    user.update(representing_company: @company)
    flash[:success] = "#{user.first_name} #{user.last_name} has been added to #{@company.name}"
    redirect_to(:action => 'show')
  end

  private

  def set_company
    begin 
      @company = Company.find(params[:id])
    rescue
      @company = nil
    end
  end

  def company_params_formatted
    new_params = company_params
    return new_params if new_params["addresses_attributes"].nil?
    new_params["addresses_attributes"].each do |addr|
      addr.last["address_type"] = addr.last["address_type"].to_i
    end
    new_params
  end

  def company_params
    params.require(:company).permit(
      :name, 
      :trading_name, 
      :website, 
      :abn, 
      :vendor_number, 
      :default_contact_id,
      addresses_attributes: [:id, :address_type, :line_1, :line_2,
        :suburb, :state, :postcode, :country]
      )
  end
 
end

