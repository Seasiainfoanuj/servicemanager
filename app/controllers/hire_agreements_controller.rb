class HireAgreementsController < ApplicationController

  layout :resolve_layout

  before_action :authenticate_user_from_token!, only: [:show, :review, :accept]
  before_action :authenticate_user!
  load_resource :find_by => :uid
  authorize_resource

  before_action :set_hire_agreement, only: [:show, :edit, :update, :destroy]

  add_crumb('Hire Agreements') { |instance| instance.send :hire_agreements_path }

  def index
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "HireAgreement").take(100)
    # if current_user.has_role? :admin
    #   if params[:vehicle_id]
    #     @vehicle = Vehicle.find(params[:vehicle_id])
    #     @hire_agreements = HireAgreement.where(:vehicle_id => @vehicle.id)
    #   else
    #     @hire_agreements = HireAgreement.all
    #   end
    # elsif current_user.has_role? :service_provider
    #   @hire_agreements = HireAgreement.where(:service_provider_id => current_user.id)
    # elsif current_user.has_role? :customer
    #   if params[:vehicle_id]
    #     @vehicle = Vehicle.find(params[:vehicle_id])
    #     @hire_agreements = HireAgreement.where(:vehicle_id => @vehicle.id)
    #   else
    #     @hire_agreements = HireAgreement.where(:customer_id => current_user.id)
    #   end
    # else
    #   @hire_agreements = []
    # end
    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Hire Agreements') { |instance| instance.send :hire_agreements_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: HireAgreementsDatatable.new(view_context, current_user) }
    end
  end

  def hire_vehicles
    @vehicles = Vehicle.where(:exclude_from_schedule => [nil, false]).joins(:hire_details).where('active') #.sort! { |a,b| a.seating_capacity <=> b.seating_capacity }
  end

  def hire_vehicles_details
    authorize! :view_hire_vehicles_details, HireAgreement
    @vehicles = Vehicle.joins(:hire_details).where('active')
  end

  def schedule_data
    authorize! :read_schedule_data, HireAgreement
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @hire_agreements = @vehicle.hire_agreements
    elsif params[:hire_schedule]
      @hire_agreements = HireAgreement.joins(vehicle: :hire_details).where(hire_vehicles: {active: true})
    else
      @hire_agreements = HireAgreement.all
    end
  end

  def customers
    @role = User.mask_for :customer
    @customers = User.where(roles_mask: @role)
  end

  def show
    @hire_agreement.create_activity :view, owner: current_user unless current_user.has_role? :admin
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "HireAgreement", :trackable_id => @hire_agreement.id)
    if @hire_agreement.off_hire_report.present?
      @off_hire_jobs = OffHireJob.order('sched_time ASC').where(off_hire_report: @hire_agreement.off_hire_report)
    end
    add_crumb @hire_agreement.uid, @hire_agreements
  end

  def review
    authorize! :review, HireAgreement
    @hire_agreement = HireAgreement.find_by_uid!(params[:id])
    @vehicle = @hire_agreement.vehicle

    unless current_user.has_role?(:customer) || current_user.has_role?(:service_provider)
      redirect_to(:action => 'show', :id => @hire_agreement.uid)
    end

    if current_user.has_role?(:customer) || current_user.has_role?(:service_provider)
      unless @hire_agreement.status == "pending" || @hire_agreement.status == "awaiting confirmation"
        redirect_to(:action => 'show', :id => @hire_agreement.uid, :user_email => params[:user_email], :user_token => params[:user_token])
      end
    end
  end

  def new
    @hire_agreement = HireAgreement.new
    add_crumb 'New Hire Agreement'
  end

  def create
    @hire_agreement = HireAgreement.new(hire_agreement_params)
    @hire_agreement.uid = 'HI-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join if @hire_agreement.uid == nil

    if @hire_agreement.type.uploads.present?
      @hire_agreement.type.uploads.each do |file|
        HireUpload.create(
          hire_agreement: @hire_agreement,
          upload: file.upload
        )
      end
      flash[:notice] = "Hire agreement type uploads added."
    end

    if @hire_agreement.save
      @hire_agreement.create_activity :create, owner: current_user
      flash[:success] = "Hire agreement created."
      redirect_to(:action => 'edit', :id => @hire_agreement.uid)
    else
      render('new')
    end
  end

  def edit
    if @hire_agreement.off_hire_report.present?
      @off_hire_jobs = OffHireJob.order('sched_time ASC').where(off_hire_report: @hire_agreement.off_hire_report)
    end

    add_crumb @hire_agreement.uid, hire_agreement_path(@hire_agreement)
    add_crumb 'Edit Hire Agreement'
  end

  def update
    if @hire_agreement.update_attributes(hire_agreement_params)
      @hire_agreement.create_activity :update, owner: current_user
      flash[:success] = "Hire agreement updated."
      redirect_to(:action => 'show')
    else
      render('edit')
    end
  end

  def accept
    @hire_agreement = HireAgreement.find_by_uid!(params[:hire_agreement_id])
    authorize! :accept, HireAgreement
    update_customer_details
    confirm_hire_agreement_details
    @hire_agreement.create_activity :accept, owner: current_user
    HireAgreementMailer.delay.accept_notification(@hire_agreement.id)
    flash[:success] = "Hire agreement accepted."
    redirect_to(:action => 'show', :id => @hire_agreement.uid, :user_email => params[:user_email], :user_token => params[:user_token])
  rescue Exception => e  
    Rails.logger.warn "HireAgreement could not be accepted"
    Rails.logger.warn e.message
    flash.now[:error] = e.message
  end

  def send_hire_agreement
    authorize! :send_hire_agreement, HireAgreement
    @hire_agreement = HireAgreement.find(params[:hire_agreement_id])
    @message = params[:message]

    HireAgreementMailer.delay.hire_agreement_email(@hire_agreement.customer.id, @hire_agreement.id, @message)
    @hire_agreement.create_activity :send, recipient: @hire_agreement.customer, owner: current_user

    @hire_agreement.status = "awaiting confirmation"
    @hire_agreement.save

    flash[:success] = "Hire agreement sent to #{@hire_agreement.customer.email}"
    redirect_to(:action => 'show', :id => @hire_agreement.uid)
  end

  def destroy
    @hire_agreement.destroy
    flash[:success] = "Hire agreement deleted."
    redirect_to(:action => 'index')
  end

  private

    def resolve_layout
      case action_name
      when "review"
        "clean"
      else
        "application"
      end
    end

    def authenticate_user_from_token!
      user_email = params[:user_email].presence
      user = user_email && User.find_by_email(user_email)

      if params[:id].presence
        hire_agreement_id = params[:id]
      elsif params[:hire_agreement_id].presence
        hire_agreement_id = params[:hire_agreement_id]
      end

      hire_agreement = hire_agreement_id && user_email && User.find_by_email(user_email).hire_agreements.find_by_uid(hire_agreement_id)

      if user && hire_agreement && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user, store: false
      end
    end

    def set_hire_agreement
      @hire_agreement = HireAgreement.find_by_uid!(params[:id])
    end

    def hire_agreement_params
      params.require(:hire_agreement).permit(
        :hire_agreement_type_id,
        :vehicle_id,
        :customer_id,
        :manager_id,
        :hire_agreement_id,
        :quote_id,
        :uid,
        :status,
        :date_range,
        :pickup_location,
        :return_location,
        :demurrage_date_range,
        :demurrage_rate,
        :seating_requirement,
        :km_out,
        :km_in,
        :fuel_in,
        :daily_km_allowance,
        :daily_rate,
        :excess_km_rate,
        :damage_recovery_fee,
        :fuel_service_fee,
        :details,
        :driver_dob,
        :licence_number,
        :state_of_issue,
        :licence_expiry_date,
        :licence_image,
        :invoice_company_id,
        customer: [
          :first_name,
          :last_name,
          :company,
          :job_title,
          :phone,
          :dob_field,
          licence: [:number, :state_of_issue, :expiry_date_field, :upload]
        ],
        customer_attributes: [
          :id,
          :first_name,
          :last_name,
          :company,
          :job_title,
          :phone,
          :dob_field,
          :avatar,
          licence_attributes: [:id, :number, :state_of_issue, :expiry_date_field, :upload]
        ],
        hire_charges_attributes: [
          :id,
          :hire_agreement_id,
          :tax_id,
          :name,
          :amount,
          :calculation_method,
          :quantity,
          :_destroy
        ]
      )
    end

    def confirm_hire_agreement_details
      @hire_agreement.driver_license_number = hire_agreement_params["customer"]["licence"]["number"],
      @hire_agreement.driver_license_state_of_issue = hire_agreement_params["customer"]["licence"]["state_of_issue"],
      @hire_agreement.driver_license_expiry = hire_agreement_params["customer"]["licence"]["expiry_date_field"],
      @hire_agreement.status = "confirmed"
      @hire_agreement.save!
    end

    def update_customer_details
      customer = @hire_agreement.customer
      customer.first_name = hire_agreement_params["customer"]["first_name"] if hire_agreement_params["customer"]["first_name"].present?
      customer.last_name = hire_agreement_params["customer"]["last_name"] if hire_agreement_params["customer"]["last_name"].present?
      nominated_company_name = hire_agreement_params["customer"]["company"] || ""
      company = find_company(customer, nominated_company_name)
      customer.representing_company_id = company ? company.id : nil
      customer.job_title = hire_agreement_params["customer"]["job_title"] if hire_agreement_params["customer"]["job_title"].present?
      customer.phone = hire_agreement_params["customer"]["phone"] if hire_agreement_params["customer"]["phone"].present?
      customer.dob = hire_agreement_params["customer"]["dob"] if hire_agreement_params["customer"]["dob"].present?
      licence_params = {
           number: hire_agreement_params["customer"]["licence"]["number"],
           state_of_issue: hire_agreement_params["customer"]["licence"]["state_of_issue"],
           expiry_date: hire_agreement_params["customer"]["licence"]["expiry_date_field"],
           upload: hire_agreement_params["customer"]["licence"]["upload"] 
      }
      if customer.licence.present?
        customer.licence.update_attributes(licence_params)
      else
        customer.licence_attributes = licence_params
      end
      customer.save!
    rescue
      Rails.logger.warn "Customer and Licence details failed validation. "
      Rails.logger.warn customer.errors.full_messages unless customer.valid?
      Rails.logger.warn "Customer: #{customer.inspect}"
      Rails.logger.warn "Licence: #{customer.licence.inspect}"
      raise ArgumentError, "Customer and Licence details failed validation. #{customer.errors.full_messages}"
    end

    def find_company(customer, nominated_name)
      search_company = nil
      if nominated_name.present? && customer.representing_company_id.nil?
        search_company = Company.find_by(name: nominated_name)
        search_company = Company.find_by(trading_name: nominated_name) if search_company.nil?
      end
      if search_company.nil?
        company = Company.create(name: nominated_name, trading_name: nominated_name)
      else
        company = search_company
      end
      company
    end

end
