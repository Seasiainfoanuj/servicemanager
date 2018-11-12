class WorkordersController < ApplicationController

  before_action :authenticate_user_from_token!, only: [:show]
  before_action :authenticate_user!
  load_and_authorize_resource :except => ['complete_step1', 'complete_step2']

  before_action :set_workorder, only: [:show, :edit, :update, :destroy]

  before_filter :set_mailer_host

  def index
    session['last_request'] = '/workorders'
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Workorder").take(100)
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
    end

    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
    if @vehicle
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
    end
    add_crumb('Workorders') { |instance| instance.send :workorders_path }

    respond_to do |format|
      format.html
      format.json { render json: WorkordersDatatable.new(view_context, current_user) }
      format.csv do
        return unless current_user.admin?
        @workorders = Workorder.includes(:vehicle, :type).map { |wo| [wo.uid, wo.type.name, wo.vehicle.name, wo.vehicle.rego_number, wo.vehicle.vehicle_number, wo.sched_time, wo.etc] }
        render csv: @workorders
      end  
    end
  end

  def schedule_data
    authorize! :read_schedule_data, Workorder
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @workorders = @vehicle.workorders
    elsif params[:hire_schedule]
      @workorders = Workorder.joins(vehicle: :hire_details).where(hire_vehicles: {active: true})
    else
      @workorders = Workorder.all
    end
  end

  def show
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Workorder", :trackable_id => @workorder.id)
    if params[:vehicle_id]
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
      add_crumb "Workorders", workorders_path(:vehicle_id => @vehicle.id)
      add_crumb @workorder.uid
    else
      add_crumb "Workorders", workorders_path
      add_crumb @workorder.uid
    end
    unless current_user.has_role? :admin
      @workorder.create_activity :view, owner: current_user
    end
  end

  def new
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @workorder = Workorder.new(:vehicle_id => @vehicle.id)
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
      add_crumb "Workorders", workorders_path(:vehicle_id => @vehicle.id)
      add_crumb "New"
    else
      @workorder = Workorder.new
      add_crumb "Workorders", workorders_path
      add_crumb "New"
    end

    if params[:po_request_id]
      po_request = PoRequest.find(params[:po_request_id])
      @workorder.vehicle_id = po_request.vehicle_id if po_request.vehicle
      @workorder.service_provider_id = po_request.service_provider_id if po_request.service_provider_id
      @workorder.sched_time = po_request.sched_time if po_request.sched_time
      @workorder.etc = po_request.etc if po_request.etc
      @workorder.details = po_request.details if po_request.details
      if po_request.update(status: 'closed')
        flash[:success] = "PO Request #{po_request.uid} closed."
      end
    end
  end

  def create
    @workorder = Workorder.new(workorder_params)
    @workorder.uid = new_workorder_uid if @workorder.uid == nil
    if @workorder.save
      @workorder.create_activity :create, owner: current_user
      flash[:success] = "Workorder created."
      redirect_to(:action => 'edit', :id => @workorder.id, :vehicle_id => @workorder.vehicle.id)
    else
      error_msg = ""
      @workorder.errors.full_messages.each { |e| error_msg << "#{e}. " }
      flash[:error] = "#{error_msg}"
      render('new')
    end
  end

  def edit
    if params[:vehicle_id]
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
      add_crumb "Workorders", workorders_path(:vehicle_id => @vehicle.id)
      add_crumb @workorder.uid, workorder_path(@workorder, :vehicle_id => @vehicle.id)
      add_crumb 'Edit'
    else
      add_crumb "Workorders", workorders_path
      add_crumb @workorder.uid, workorder_path(@workorder)
      add_crumb 'Edit'
    end
    @workorder.build_sp_invoice unless @workorder.sp_invoice
  end

  def update
    if @workorder.update_attributes(workorder_params)
      @workorder.create_activity :update, owner: current_user
      flash[:success] = "Workorder updated."
      redirect_to(:action => 'show', :id => @workorder.id, :vehicle_id => @workorder.vehicle.id)
    else
      error_msg = ""
      @workorder.errors.full_messages.each { |e| error_msg << "#{e}. " }
      flash[:error] = "#{error_msg}"
      render('edit')
    end
  end

  def complete_step1
    @workorder = Workorder.find(params[:workorder_id])
    authorize! :complete, @workorder

    if @workorder.vehicle_log
      @vehicle_log = @workorder.vehicle_log
      flash[:notice] = "Workorder logbook entry already existed. Finish by updating the log entry details below."
    else
      @vehicle_log = VehicleLog.create(
          :uid => 'LOG-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join,
          :workorder_id => @workorder.id,
          :name => @workorder.type.name,
          :vehicle_id => @workorder.vehicle.id,
          :service_provider_id => @workorder.service_provider_id
        )
      flash[:success] = "Workorder completed and log entry created. Finish by updating the log entry details below."
    end

    if params[:create_recurring_workorder]
      if @workorder.status == 'complete'
        flash[:error] = "Recurring workorder already has been created."
      else
        @new_workorder = Workorder.create(
          :workorder_type_id => @workorder.workorder_type_id,
          :invoice_company_id => @workorder.invoice_company_id,
          :vehicle_id => @workorder.vehicle_id,
          :uid => new_workorder_uid,
          :status => "confirmed",
          :is_recurring => @workorder.is_recurring,
          :recurring_period_field => @workorder.recurring_period_field,
          :service_provider_id => @workorder.service_provider_id,
          :customer_id => @workorder.customer_id,
          :manager_id => @workorder.manager_id,
          :sched_time => @workorder.next_workorder_date,
          :etc => @workorder.next_workorder_etc
          )
        flash[:notice] = "Recurring workorder created. <span class='label label-grey'>Ref #{@new_workorder.uid}</span>".html_safe
      end
    end

    unless @workorder.status == 'complete'
      @workorder.status = "complete"
      if @workorder.save
        @workorder.create_activity :complete, owner: current_user
        # Send email notifications
        if @workorder.manager
          WorkorderMailer.delay.workorder_notification(@workorder.manager.id, @workorder.id, "completed")
        end
        if @workorder.service_provider
          WorkorderMailer.delay.workorder_notification(@workorder.service_provider.id, @workorder.id, "completed")
        end
        if @workorder.customer
          WorkorderMailer.delay.workorder_notification(@workorder.customer.id, @workorder.id, "completed")
        end
      end
    end

    add_crumb('Workorders') { |instance| instance.send :workorders_path }
    add_crumb @workorder.uid, workorder_path(@workorder)
    add_crumb 'Complete'
  end

  def complete_step2
    @workorder = Workorder.find(params[:workorder_id])
    authorize! :complete, @workorder

    @workorder.build_sp_invoice

    add_crumb('Workorders') { |instance| instance.send :workorders_path }
    add_crumb @workorder.uid, workorder_path(@workorder)
    add_crumb 'Complete'
    add_crumb 'Submit Invoice'
  end

  def submit_sp_invoice
    authorize! :submit_sp_invoice, @workorder
    if @workorder.update_attributes(params.require(:workorder).permit(
        sp_invoice_attributes: [:id, :job_id, :job_type, :invoice_number, :upload, :delete_upload]
      ))
      @workorder.create_activity :sp_invoice_submitted, owner: current_user
      @workorder.sp_invoice.create_activity :submit, owner: current_user

      if @workorder.invoice_company && @workorder.invoice_company.accounts_admin
        SpInvoiceMailer.notification_email(@workorder.invoice_company.accounts_admin.id, @workorder.sp_invoice.id)
      end

      flash[:success] = "Invoice submitted."
      redirect_to(:action => 'show', :id => @workorder.id, :vehicle_id => @workorder.vehicle.id)
    else
      render('complete_step2')
    end
  end

  def send_notifications
    authorize! :send_notifications, Workorder

    @workorder = Workorder.find(params[:workorder_id])
    @workorder.status = "confirmed"
    @workorder.save!
    @message = params[:message]

    flash_message = "Workorder notification email sent to "
    original_length = flash_message.length

    if params[:send_to_customer] == "true"
      WorkorderMailer.delay.notification_email(@workorder.customer.id, @workorder.id, @message)
      @workorder.create_activity :send, recipient: @workorder.customer, owner: current_user
      flash_message += "#{@workorder.customer.email}"
    end

    if params[:send_to_customer] == "true" && params[:send_to_service_provider] == "true"
      flash_message += " & "
    end

    if params[:send_to_service_provider] == "true"
      WorkorderMailer.delay.notification_email(@workorder.service_provider.id, @workorder.id, @message)
      @workorder.create_activity :send, recipient: @workorder.service_provider, owner: current_user
      flash_message += "#{@workorder.service_provider.email}"
    end

    if params[:send_to_customer] == "true" && params[:send_to_manager] == "true" || params[:send_to_service_provider] == "true" && params[:send_to_manager] == "true"
      flash_message += " & "
    end

    if params[:send_to_manager] == "true"
      WorkorderMailer.delay.notification_email(@workorder.manager.id, @workorder.id, @message)
      @workorder.create_activity :send, recipient: @workorder.manager, owner: current_user
      flash_message += "#{@workorder.manager.email}"
    end

    subscriber_emails = []

    if params[:send_to_subscribers] == "true"
      subscriber_ids = params[:send_to_subscriber_recipients].gsub(' ', '').split(',')
      subscriber_ids.each do |id|
        WorkorderMailer.delay.notification_email(id, @workorder.id, @message)
        email = User.find(id).email
        subscriber_emails << email
      end
      flash_message += subscriber_emails.to_sentence
    end

    invalid_emails = []
    valid_emails = []
    if params[:send_to_others] == "true"
      emails = params[:send_to_others_receipients].gsub(' ', '').split(',')
      emails.each do |email|
        if email =~ /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/
          WorkorderMailer.delay.notification_email_others(email, @workorder.id, @message)
          valid_emails << email
        else
          invalid_emails << email
        end
        #@workorder.create_activity :send, recipient: email, owner: current_user  # email needs to be a User
      end
      flash_message += " & " if flash_message.length != original_length
      flash_message += valid_emails.to_sentence
    end

    success = flash_message.length != original_length

    flash_message += " with message." unless @message.blank?

    flash[:success] = flash_message if success
    flash[:error] = "Could not send workorder notification to #{invalid_emails.to_sentence}." if invalid_emails.length > 0
    redirect_to(:action => 'show', :id => @workorder.id)
  end

  def save_to_log
    if @workorder.update_attributes(workorder_params)
      flash[:success] = "Workorder updated."
      redirect_to(:action => 'show', :id => @workorder.id, :vehicle_id => @workorder.vehicle.id)
    else
      render('edit')
    end
  end

  def destroy
    @workorder.destroy
    if @workorder.manager
      WorkorderMailer.delay.workorder_notification(@workorder.manager.id, @workorder.id, "deleted")
    end
    flash[:success] = "Workorder deleted."
    redirect_to(:action => 'index')
  end

private

  def authenticate_user_from_token!
    user_email = params[:user_email].presence
    user       = user_email && User.find_by_email(user_email)
    return false unless user
    if params[:id].presence
      workorder_id   = params[:id]
    elsif params[:workorder_id].presence
      workorder_id = params[:workorder_id]
    end
    if user.admin? 
      sign_in user
    elsif user.service_provider?
      return unless workorder_id.present?
      wo = Workorder.where(id: workorder_id)
      return unless wo.any?
      return unless wo.first.service_provider == user
      sign_in user
    elsif user.customer?
      workorder = workorder_id && user_email && user.customer_workorders.find_by_id(workorder_id)
      if workorder && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user, store: false
      end
    end
  end

  def set_workorder
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @workorder = Workorder.find(params[:id])
    else
      @workorder = Workorder.find(params[:id])
    end
  end

  def workorder_params
    params.require(:workorder).permit(
      :workorder_type_id,
      :vehicle_id,
      :invoice_company_id,
      :uid,
      :status,
      :is_recurring,
      :recurring_period_field,
      :service_provider_id,
      :customer_id,
      :manager_id,
      :sched_date_field,
      :sched_time_field,
      :etc_date_field,
      :etc_time_field,
      :details,
      job_subscribers_attributes: [:id, :job_id, :user_id, :_destroy],
      sp_invoice_attributes: [:id, :job_id, :job_type, :invoice_number, :upload, :delete_upload]
    )
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

end
