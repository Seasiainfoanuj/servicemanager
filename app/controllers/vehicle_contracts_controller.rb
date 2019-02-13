class VehicleContractsController < ApplicationController

  before_action :authenticate_user_from_token!, only: [:show, :review, :view_customer_contract, :accept, :upload_contract]
  before_action :authenticate_user!
  authorize_resource

  layout :resolve_layout
  
  before_action :set_vehicle_contract, except: [:index, :destroy]

  add_crumb('Vehicle Contracts') { |instance| instance.send :vehicle_contracts_path }

  def show
    if current_user.roles.exclude?(:admin) && 
      @vehicle_contract.customer != current_user
      redirect_to(action: :index) and return
    end    
          
    respond_to do |format|
      format.html do
        redirect_to(action: :index) and return unless current_user.admin?
        set_contract_presenter
        add_crumb @vehicle_contract.uid
        @vehicle_contract.build_signed_contract unless @vehicle_contract.signed_contract
        @activities = @vehicle_contract.activities.order("created_at desc")
      end
      
      format.pdf do
        if current_user == @vehicle_contract.customer
          @vehicle_contract.create_activity :view, owner: current_user
        end
        pdf = VehicleContractPdf.new(@vehicle_contract, view_context)
        send_data pdf.render, filename: "contract-#{@vehicle_contract.uid}.pdf",
                              type: "application/pdf",
                              disposition: "inline"
      end
    end

  end

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Vehicle Contracts') { |instance| instance.send :vehicle_contracts_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: VehicleContractsDatatable.new(view_context, current_user, params[:mode]) }
    end
  end

  def new
    quote = Quote.find_by(number: params[:quote_number])
    unless quote && quote.status == 'accepted'
      flash[:error] = "Quote cannot not used to create Vehicle Contract."
      redirect_to :back and return
    end
    @vehicle_contract = VehicleContract.new(quote_id: quote.id, customer_id: quote.customer.id,
                 manager_id: quote.manager.id, invoice_company_id: quote.invoice_company.id)
    set_contract_presenter
    add_crumb 'New Vehicle Contract'
  end

  def create
    @vehicle_contract = VehicleContract.new(vehicle_contract_params)
    if ["", nil].exclude?(vehicle_contract_params[:allocated_stock_id])
      if ["", nil].exclude?(vehicle_contract_params[:vehicle_id])
        flash[:error] = "Choose either the Allocated Stock or Vehicle, but not both."
        set_contract_presenter
        render 'new' and return
      end
      unless VehicleContractManager.can_replace_allocated_stock_with_vehicle?(vehicle_contract_params[:allocated_stock_id])
        flash[:error] = "A vehicle with this VIN number already exists in the database. Selected allocated stock might be invalid."
        set_contract_presenter
        render 'new' and return
      end
    end  
    if @vehicle_contract.valid?
      @vehicle_contract.save!
      VehicleContractManager.finalise_new_contract(@vehicle_contract, current_user)
      flash[:success] = "Vehicle Contract created."
      redirect_to(action: :show, id: @vehicle_contract, referrer: "created")
    else
      flash[:error] = "Vehicle Contract could not be created."
      set_contract_presenter
      render 'new' and return
    end
  end

  def edit
    options = { current_status: @vehicle_contract.current_status, 
                current_user: current_user, 
                signed_contract_exists: @vehicle_contract.signed_contract.present? } 
    unless VehicleContractStatusManager.action_permitted?(:update, options)
      flash[:error] = "A vehicle contract with status of #{@vehicle_contract.status_name} may not be updated."
      redirect_to(:action => 'show', :id => @vehicle_contract.uid) and return
    end
    add_crumb @vehicle_contract.uid, vehicle_contract_path(@vehicle_contract)
    set_contract_presenter
    add_crumb 'Edit Vehicle Contract'
    if VehicleContractStatusManager.action_permitted?(:upload_contract, options)
      @vehicle_contract.build_signed_contract unless @vehicle_contract.signed_contract
    end
  end

  def update
    options = { current_status: @vehicle_contract.current_status } 
    unless VehicleContractStatusManager.action_permitted?(:update, options)
      flash[:error] = "A vehicle contract with status of #{@vehicle_contract.status_name} may not be updated."
      redirect_to(:action => 'show', :id => @vehicle_contract.uid) and return
    end
    new_params = vehicle_contract_params
    if new_params["signed_contract_attributes"].present? && new_params["signed_contract_attributes"]["upload"].present?
      new_params["signed_contract_attributes"]["uploaded_by_id"] = current_user.id
      new_params["signed_contract_attributes"]["uploaded_location_ip"] = request.remote_ip
    end  

    if @vehicle_contract.update(new_params)
      @vehicle_contract.create_activity :update, owner: current_user
      flash[:success] = "Vehicle Contract updated."
      redirect_to(action: :show, referrer: "updated")
    else
      flash[:error] = "Vehicle Contract could not be updated."
      set_contract_presenter
      render :edit
    end
  end

  def terms_conditions_download
    send_file(
      "#{Rails.root}/app/assets/images/legal/Bus 4x4 Vehicle Terms and Conditions V2.pdf", filename: "Vehicle Purchase Terms and Conditions.pdf",
      type: "application/pdf"
    )
  end

  def view_customer_contract
    redirect_to(action: :index) and return if @vehicle_contract.nil?
    authorize! :view_customer_contract, VehicleContract
    options = { current_status: @vehicle_contract.current_status, current_user: current_user } 
    unless VehicleContractStatusManager.action_permitted?(:view_customer_contract, options)
      flash[:error] = "Access to this contract is not permitted."
      redirect_to(action: :index) and return
    end
    @vehicle_contract.create_activity(:customer_contract, owner: current_user) unless current_user.admin?
    set_contract_presenter
    @vehicle_contract.build_signed_contract unless @vehicle_contract.signed_contract
  rescue
    flash[:error] = "Unexpected error occurred when loading contract data"  
    redirect_to(action: :index)
  end

  def upload_contract
    redirect_to(action: :index) and return if @vehicle_contract.nil?
    authorize! :upload_contract, VehicleContract
    if params[:vehicle_contract].blank?
      flash[:error] = "A file has not yet been selected."
      redirect_to :back and return
    end
    options = { current_status: @vehicle_contract.current_status, 
                current_user: current_user, 
                signed_contract_exists: @vehicle_contract.signed_contract.present? } 
    unless VehicleContractStatusManager.action_permitted?(:upload_contract, options)
      flash[:error] = "This action is currently not permitted."
      redirect_to(action: :index) and return
    end
    new_params = include_uploader_details(vehicle_contract_params)

    respond_to do |format|
      if @vehicle_contract.update(new_params)
        format.html {
          VehicleContractManager.complete_upload(@vehicle_contract, current_user)
          VehicleContractMailer.delay.upload_notification_email(@vehicle_contract.id)
          flash[:success] = "Vehicle Contract has been uploaded."
          redirect_to :back and return
        }
        format.json { render json: {files: [@vehicle_contract.signed_contract.to_jq_upload]}, status: :created, location: @vehicle_contract.signed_contract }
      else
        format.html {
          flash[:error] = "Vehicle Contract could not be uploaded."
          redirect_to :back and return
        }
        format.json { render json: @vehicle_contract.signed_contract.errors, status: :unprocessable_entity }
      end
    end
  end

  def verify_customer_info
    options = { current_status: @vehicle_contract.current_status } 
    unless VehicleContractStatusManager.action_permitted?(:verify_customer_info, options)
      flash[:error] = "A vehicle contract with status of #{@vehicle_contract.status_name} may not be verified."
      redirect_to(:action => 'show', :id => @vehicle_contract.uid) and return
    end
    if @vehicle_contract.vehicle.blank?
      flash[:error] = "A vehicle must first be selected before the contract can be verified. Edit the contract to accomplish this."
      redirect_to(:action => 'show', :id => @vehicle_contract.uid) and return
    end
    VehicleContractManager.complete_verification(@vehicle_contract, current_user)
    flash[:success] = "The customer details for this contract have been verified."
    redirect_to(:action => 'show', :referrer => "verify_customer_info")
  rescue
    flash[:error] = "Verification failed!"
    redirect_to vehicle_contract_path(@vehicle_contract)
  end

  def send_contract
    authorize! :send_contract, VehicleContract
    options = { current_status: @vehicle_contract.current_status } 
    unless VehicleContractStatusManager.action_permitted?(:send_contract, options)
      flash[:error] = "A vehicle contract with a status of #{@vehicle_contract.status_name} may not be sent."
      redirect_to(:action => 'show', :id => @vehicle_contract.uid) and return
    end
    if @vehicle_contract.vehicle_id.blank?
      flash[:error] = "A vehicle contract requires a vehicle before it can be sent to the customer."
      redirect_to(:action => 'show', :id => @vehicle_contract.uid) and return
    end
    @message = params[:message]
    VehicleContractManager.prepare_contract_for_sending(@vehicle_contract, current_user)
    VehicleContractMailer.delay.vehicle_contract_email(@vehicle_contract.customer.id, current_user.id, @vehicle_contract.id, @message)
    flash[:success] = "Vehicle Contract sent to #{@vehicle_contract.customer.email}."
    redirect_to(:action => 'show', :id => @vehicle_contract.uid)
  rescue
    flash[:error] = "Contract could not be sent!"
    redirect_to vehicle_contract_path(@vehicle_contract)
  end

  def review
    authorize! :review, VehicleContract
    options = { current_status: @vehicle_contract.current_status } 
    unless VehicleContractStatusManager.action_permitted?(:review, options)
      flash[:error] = "A vehicle contract with a status of #{@vehicle_contract.status_name} may not be reviewed."
      redirect_to(:action => 'show', :id => @vehicle_contract.uid) and return
    end
    @vehicle_contract.build_signed_contract unless @vehicle_contract.signed_contract
    @vehicle_contract.create_activity :review_notice, owner: current_user
    set_contract_presenter
  end

  def accept
    authorize! :accept, VehicleContract
    options = { current_status: @vehicle_contract.current_status } 
    unless VehicleContractStatusManager.action_permitted?(:accept, options)
      flash[:error] = "A vehicle contract with a status of #{@vehicle_contract.status_name} may not be accepted."
      redirect_to(:action => 'view_customer_contract', :id => @vehicle_contract.uid) and return
    end
    options = {current_user: current_user, ip_address: request.remote_ip}
    VehicleContractManager.complete_acceptance(@vehicle_contract, options)
    VehicleContractMailer.delay.accept_notification_email(@vehicle_contract.id)
    flash[:success] = "Vehicle Contract accepted."
    redirect_to(:action => 'view_customer_contract', :id => @vehicle_contract.uid, :user_email => params[:user_email], :user_token => params[:user_token]) and return
  rescue Exception => e  
    Rails.logger.warn "VehicleContract could not be accepted"
    Rails.logger.warn e.message
    flash.now[:error] = e.message
  end

  private

    def authenticate_user_from_token!
      user_email = params[:user_email].presence
      user       = user_email && User.find_by(email: user_email)
      vehicle_contract_uid = params[:id] || nil

      vehicle_contract = vehicle_contract_uid && user_email && User.find_by(email: user_email).vehicle_contracts.find_by(uid: vehicle_contract_uid)
      if user && vehicle_contract && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user, store: false
      end
    end

    def set_vehicle_contract
      if params[:vehicle_contract_id].present?
        @vehicle_contract = VehicleContract.find_by(uid: params[:vehicle_contract_id])
      else
        @vehicle_contract = VehicleContract.find_by(uid: params[:id])
      end
    end

    def vehicle_contract_params
      params.require(:vehicle_contract).permit(
        :quote_id,
        :invoice_company_id,
        :manager_id,
        :customer_id,
        :allocated_stock_id,
        :vehicle_id,
        :registration_cost,
        :stamp_duty_cost,
        :ctp_insurance,
        :additional_items,
        :deposit_received,
        :deposit_received_date_field,
        :special_conditions,
        signed_contract_attributes: [:id, :upload]
      )
    end

    def set_contract_presenter
      @view_contract = VehicleContractPresenter.new(@vehicle_contract)
    end

    def include_uploader_details(vehicle_contract_params)
      new_params = vehicle_contract_params
      if new_params["signed_contract_attributes"].present? && new_params["signed_contract_attributes"]["upload"].present?
        new_params["signed_contract_attributes"]["uploaded_by_id"] = current_user.id
        new_params["signed_contract_attributes"]["uploaded_location_ip"] = request.remote_ip
      end  
      new_params
    end

    def resolve_layout
      case action_name
      when "review"
        "clean"
      else
        "application"
      end
    end

end