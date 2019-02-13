class BuildOrdersController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource :except => ['complete_step1', 'complete_step2', 'complete_submit']

  before_action :set_build_order, only: [:show, :edit, :update, :destroy]

  add_crumb("Build Orders") { |instance| instance.send :builds_path }

  def index
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "BuildOrder").take(100)
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Build Orders') { |instance| instance.send :build_orders_path }
    end

    @vehicle = Vehicle.find(params[:vehicle_id]) if params[:vehicle_id]
    if @vehicle
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
      add_crumb("Build Orders") { |instance| instance.send :builds_path }
    end


    respond_to do |format|
      format.html
      format.json { render json: BuildOrdersDatatable.new(view_context, current_user) }
    end
  end

  def schedule_data
    authorize! :read_schedule_data, BuildOrder
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @build_orders = @vehicle.build.build_orders if @vehicle.build
    elsif params[:hire_schedule]
      @workorders = BuildOrder.joins(build: [vehicle: :hire_details]).where(hire_vehicles: {active: true})
    else
      @build_orders = BuildOrder.all
    end
  end

  def show
    @build_order.create_activity :view, owner: current_user unless current_user.has_role? :admin
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "BuildOrder", :trackable_id => @build_order.id)
    add_crumb @build_order.uid, @build_orders
  end

  def new
    @build_order = BuildOrder.new
    if params[:build_id]
      @build = Build.find(params[:build_id])
      @build_order.build_id = @build.id
    end
    add_crumb "New"
  end

  def create
    @build_order = BuildOrder.new(build_order_params)
    @build_order.uid = 'MA-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join if @build_order.uid == nil
    if @build_order.save
      @build_order.create_activity :create, owner: current_user
      flash[:success] = "Build order added."
      redirect_to(:controller => 'builds', :action => 'show', :id => @build_order.build.id)
    else
      render 'new'
    end
  end

  def edit
    @build = @build_order.build
    @build_order.build_sp_invoice unless @build_order.sp_invoice
    add_crumb @build_order.uid, @build_orders
    add_crumb 'Edit'
  end

  def update
    if @build_order.update(build_order_params)
      @build_order.create_activity :update, owner: current_user
      if @build_order.status == "complete"
        if @build_order.manager
          BuildOrderMailer.delay.build_order_notification(@build_order.manager_id, @build_order.id, "completed")
        end
        if @build_order.service_provider
          BuildOrderMailer.delay.build_order_notification(@build_order.service_provider_id, @build_order.id, "completed")
        end
        flash[:success] = "Build order completed."
      else
        flash[:success] = "Build order updated."
      end
      if current_user.has_role? :admin
        redirect_to(:controller => 'builds', :action => 'show', :id => @build_order.build.id)
      else
        redirect_to(:action => 'show', :id => @build_order.id)
      end
    else
      render('edit')
    end
  end

  def complete_step1
    @build_order = BuildOrder.find(params[:build_order_id])
    authorize! :complete, @build_order

    @build = @build_order.build

    add_crumb @build_order.uid, build_order_path(@build_order)
    add_crumb 'Complete'
  end

  def complete_step2
    @build_order = BuildOrder.find(params[:build_order_id])
    authorize! :complete, @build_order

    @build_order.build_sp_invoice

    add_crumb @build_order.uid, build_order_path(@build_order)
    add_crumb 'Complete'
    add_crumb 'Submit Invoice'
  end

  def complete_submit
    @build_order = BuildOrder.find(params[:id])
    authorize! :complete, @build_order

    if @build_order.update(build_order_params)
      @build_order.create_activity :complete, owner: current_user

      if @build_order.manager
        BuildOrderMailer.delay.build_order_notification(@build_order.manager_id, @build_order.id, "completed")
      end

      if @build_order.service_provider
        BuildOrderMailer.delay.build_order_notification(@build_order.service_provider_id, @build_order.id, "completed")
      end

      redirect_to(:action => 'complete_step2', :build_order_id => @build_order.id)
    else
      render('complete_step1')
    end
  end

  def submit_sp_invoice
    @build_order = BuildOrder.find(params[:id])
    authorize! :submit_sp_invoice, @build_order

    if @build_order.update_attributes(params.require(:build_order).permit(
        sp_invoice_attributes: [:id, :job_id, :job_type, :invoice_number, :upload, :delete_upload]
      ))
      @build_order.create_activity :sp_invoice_submitted, owner: current_user
      @build_order.sp_invoice.create_activity :submit, owner: current_user

      if @build_order.invoice_company && @build_order.invoice_company.accounts_admin
        SpInvoiceMailer.delay.notification_email(@build_order.invoice_company.accounts_admin.id, @build_order.sp_invoice.id)
      end

      flash[:success] = "Build order complete and invoice submitted."

      if current_user.has_role? :admin
        redirect_to(:controller => 'builds', :action => 'show', :id => @build_order.build.id)
      else
        redirect_to(:action => 'show', :id => @build_order.id)
      end
    else
      render('complete_step2')
    end
  end

  def destroy
    @build_order.destroy
    flash[:success] = "Build order deleted."
    redirect_to(:controller => 'builds', :action => 'show', :id => @build_order.build.id)
  end

  def send_notifications
    authorize! :send_notifications, BuildOrder

    @build_order = BuildOrder.find(params[:build_order_id])
    @message = params[:message]

    flash_message = "Build order notification email sent to "

    if params[:send_to_service_provider] == "true"
      BuildOrderMailer.delay.notification_email(@build_order.service_provider_id, @build_order.id, @message)
      @build_order.create_activity :send, recipient: @build_order.service_provider, owner: current_user
      flash_message += "#{@build_order.service_provider.email}"
    end

    if params[:send_to_service_provider] == "true" && params[:send_to_manager] == "true"
      flash_message += " & "
    end

    if params[:send_to_manager] == "true"
      BuildOrderMailer.delay.notification_email(@build_order.manager_id, @build_order.id, @message)
      @build_order.create_activity :send, recipient: @build_order.manager, owner: current_user
      flash_message += "#{@build_order.manager.email}"
    end

    subscriber_emails = []

    if params[:send_to_subscribers] == "true"
      subscriber_ids = params[:send_to_subscriber_recipients].gsub(' ', '').split(',')
      subscriber_ids.each do |id|
        BuildOrderMailer.delay.notification_email(id, @build_order.id, @message)
        email = User.find(id).email
        subscriber_emails << email
      end
      flash_message += subscriber_emails.to_sentence
    end

    flash_message += " with message." unless @message.blank?

    flash[:success] = flash_message
    redirect_to(:action => 'show', :id => @build_order.id)
  end

private

  def set_build_order
    @build_order = BuildOrder.find(params[:id])
  end

  def build_order_params
    params.require(:build_order).permit(
      :uid,
      :build_id,
      :invoice_company_id,
      :service_provider_id,
      :manager_id,
      :sched_date_field,
      :sched_time_field,
      :etc_date_field,
      :etc_time_field,
      :name,
      :status,
      :details,
      :service_provider_notes,
      job_subscribers_attributes: [:id, :job_id, :user_id, :_destroy],
      sp_invoice_attributes: [:id, :job_id, :job_type, :upload, :invoice_number, :delete_upload]
    )
  end

end
