class OffHireJobsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource :except => ['complete_step1', 'complete_step2', 'complete_submit']

  before_action :set_off_hire_job, only: [:show, :edit, :update, :destroy]

  add_crumb("Off Hire Jobs") { |instance| instance.send :off_hire_jobs_path }

  def index
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "OffHireJob").take(100)
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
    add_crumb('Off Hire Jobs') { |instance| instance.send :off_hire_jobs_path }

    respond_to do |format|
      format.html
      format.json { render json: OffHireJobsDatatable.new(view_context, current_user) }
    end
  end

  def schedule_data
    authorize! :read_schedule_data, OffHireJob
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @off_hire_jobs = OffHireJob.joins(off_hire_report: [hire_agreement: :vehicle]).where(vehicles: {id: @vehicle.id})
    elsif params[:hire_schedule]
      @off_hire_jobs = OffHireJob.joins(off_hire_report: [hire_agreement: [vehicle: :hire_details]]).where(hire_vehicles: {active: true})
    else
      @off_hire_jobs = OffHireJob.all
    end
  end

  def show
    @off_hire_job.create_activity :view, owner: current_user unless current_user.has_role? :admin
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "OffHireJob", :trackable_id => @off_hire_job.id)
    add_crumb @off_hire_job.uid, @off_hire_jobs
  end

  def new
    @off_hire_job = OffHireJob.new
    if params[:off_hire_report_id]
      @off_hire_report = OffHireReport.find(params[:off_hire_report_id])
      @off_hire_job.off_hire_report_id = @off_hire_report.id
    end
    add_crumb "New"
  end

  def create
    @off_hire_job = OffHireJob.new(off_hire_job_params)
    @off_hire_job.uid = 'HJ-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join if @off_hire_job.uid == nil
    if @off_hire_job.save
      @off_hire_job.create_activity :create, owner: current_user
      flash[:success] = "Off Hire Job added."
      redirect_to(:action => 'show', :id => @off_hire_job.id, :off_hire_report => @off_hire_job.off_hire_report_id)
    else
      render 'new'
    end
  end

  def edit
    @off_hire_report = @off_hire_job.off_hire_report
    @off_hire_job.build_sp_invoice unless @off_hire_job.sp_invoice
    add_crumb @off_hire_job.uid, @off_hire_jobs
    add_crumb 'Edit'
  end

  def update
    if @off_hire_job.update(off_hire_job_params)
      @off_hire_job.create_activity :update, owner: current_user
      if @off_hire_job.status == "complete"
        if @off_hire_job.manager
          OffHireJobMailer.delay.off_hire_job_notification(@off_hire_job.manager_id, @off_hire_job.id, "completed")
        end
        if @off_hire_job.service_provider
          OffHireJobMailer.delay.off_hire_job_notification(@off_hire_job.service_provider_id, @off_hire_job.id, "completed")
        end
        @off_hire_job.create_activity :complete, owner: current_user
        flash[:success] = "Off Hire Job completed."
      else
        flash[:success] = "Off Hire Job updated."
      end
      redirect_to(:action => 'show', :id => @off_hire_job.id, :off_hire_report => @off_hire_job.off_hire_report_id)
    else
      render('edit')
    end
  end

  def complete_step1
    @off_hire_job = OffHireJob.find(params[:off_hire_job_id])
    authorize! :complete, @off_hire_job

    @off_hire_report = @off_hire_job.off_hire_report

    add_crumb @off_hire_job.uid, off_hire_job_path(@off_hire_job)
    add_crumb 'Complete'
  end

  def complete_step2
    @off_hire_job = OffHireJob.find(params[:off_hire_job_id])
    authorize! :complete, @off_hire_job

    @off_hire_job.build_sp_invoice

    add_crumb @off_hire_job.uid, off_hire_job_path(@off_hire_job)
    add_crumb 'Complete'
    add_crumb 'Submit Invoice'
  end

  def complete_submit
    @off_hire_job = OffHireJob.find(params[:id])
    authorize! :complete, @off_hire_job

    if @off_hire_job.update(off_hire_job_params)
      @off_hire_job.create_activity :complete, owner: current_user

      if @off_hire_job.manager
        OffHireJobMailer.delay.off_hire_job_notification(@off_hire_job.manager_id, @off_hire_job.id, "completed")
      end

      if @off_hire_job.service_provider
        OffHireJobMailer.delay.off_hire_job_notification(@off_hire_job.service_provider_id, @off_hire_job.id, "completed")
      end

      redirect_to(:action => 'complete_step2', :off_hire_job_id => @off_hire_job.id)
    else
      render('complete_step1')
    end
  end

  def submit_sp_invoice
    @off_hire_job = OffHireJob.find(params[:id])
    authorize! :submit_sp_invoice, @off_hire_job

    if @off_hire_job.update_attributes(params.require(:off_hire_job).permit(
        sp_invoice_attributes: [:id, :job_id, :job_type, :invoice_number, :upload, :delete_upload]
      ))
      @off_hire_job.create_activity :sp_invoice_submitted, owner: current_user
      @off_hire_job.sp_invoice.create_activity :submit, owner: current_user

      if @off_hire_job.invoice_company && @off_hire_job.invoice_company.accounts_admin
        SpInvoiceMailer.delay.notification_email(@off_hire_job.invoice_company.accounts_admin.id, @off_hire_job.sp_invoice.id)
      end

      flash[:success] = "Build order complete and invoice submitted."
      redirect_to(:action => 'show', :id => @off_hire_job.id, :off_hire_report => @off_hire_job.off_hire_report_id)
    else
      render('complete_step2')
    end
  end

  def destroy
    @off_hire_job.destroy
    flash[:success] = "Off Hire Job deleted."
    redirect_to @off_hire_job.off_hire_report.hire_agreement
  end

  def send_notifications
    authorize! :send_notifications, OffHireJob

    @off_hire_job = OffHireJob.find(params[:off_hire_job_id])
    @message = params[:message]

    flash_message = "Off Hire Job notification email sent to "

    if params[:send_to_service_provider] == "true"
      OffHireJobMailer.delay.notification_email(@off_hire_job.service_provider_id, @off_hire_job.id, @message)
      @off_hire_job.create_activity :send, recipient: @off_hire_job.service_provider, owner: current_user
      flash_message += "#{@off_hire_job.service_provider.email}"
    end

    if params[:send_to_service_provider] == "true" && params[:send_to_manager] == "true"
      flash_message += " & "
    end

    if params[:send_to_manager] == "true"
      OffHireJobMailer.delay.notification_email(@off_hire_job.manager_id, @off_hire_job.id, @message)
      @off_hire_job.create_activity :send, recipient: @off_hire_job.manager, owner: current_user
      flash_message += "#{@off_hire_job.manager.email}"
    end

    subscriber_emails = []

    if params[:send_to_subscribers] == "true"
      subscriber_ids = params[:send_to_subscriber_recipients].gsub(' ', '').split(',')
      subscriber_ids.each do |id|
        OffHireJobMailer.delay.notification_email(id, @off_hire_job.id, @message)
        email = User.find(id).email
        subscriber_emails << email
      end
      flash_message += subscriber_emails.to_sentence
    end

    flash_message += " with message." unless @message.blank?

    flash[:success] = flash_message
    redirect_to(:action => 'show', :id => @off_hire_job.id)
  end

  private

    def set_off_hire_job
      @off_hire_job = OffHireJob.find(params[:id])
    end

    def off_hire_job_params
      params.require(:off_hire_job).permit(
        :uid,
        :off_hire_report_id,
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
        :service_provider_notes, :vehicle_id,
        off_hire_reports_attributes: [ hire_agreements_attributes: [:vehicle_id]],
        job_subscribers_attributes: [:id, :job_id, :user_id, :_destroy],
        sp_invoice_attributes: [:id, :job_id, :job_type, :upload, :invoice_number, :delete_upload]
      )
    end

end
