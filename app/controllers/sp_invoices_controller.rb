class SpInvoicesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_sp_invoice, only: [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html { add_crumb "Sp Invoices" }
      format.json { render json: SpInvoicesDatatable.new(view_context, current_user) }
    end
  end

  def show
    @activities = PublicActivity::Activity.order("created_at desc")
                                          .where(:trackable_type => "SpInvoice",
                                                 :trackable_id => @sp_invoice.id)

    if @sp_invoice.job_type == 'Workorder'
      @vehicle = @sp_invoice.workorder.vehicle
    elsif @sp_invoice.job_type == 'BuildOrder'
      @vehicle = @sp_invoice.build_order.build.vehicle
    elsif @sp_invoice.job_type == 'OffHireJob'
      @vehicle = @sp_invoice.off_hire_job.off_hire_report.hire_agreement.vehicle
    end

    unless params[:referrer] == "updated"
      @sp_invoice.create_activity :view, owner: current_user

      if @sp_invoice.status == "invoice received"
        @sp_invoice.update(:status => "viewed")
      end
    end

    add_crumb "Sp Invoices", sp_invoices_path
    add_crumb @sp_invoice.invoice_number
  end

  def submit
    authorize! :submit, SpInvoice

    @sp_invoice = SpInvoice.new

    if params[:workorder_id]
      @sp_invoice.job = Workorder.find(params[:workorder_id])
      add_crumb "Workorders", workorders_path
      add_crumb @sp_invoice.job.uid, workorder_path(@sp_invoice.job)
    elsif params[:build_order_id]
      @sp_invoice.job = BuildOrder.find(params[:build_order_id])
      add_crumb "Build Orders", build_orders_path
      add_crumb @sp_invoice.job.uid, build_order_path(@sp_invoice.job)
    elsif params[:off_hire_job_id]
      @sp_invoice.job = OffHireJob.find(params[:off_hire_job_id])
      add_crumb "Off Hire Jobs", off_hire_jobs_path
      add_crumb @sp_invoice.job.uid, off_hire_job_path(@sp_invoice.job)
    end

    if @sp_invoice.job.sp_invoice
      flash[:error] = "Invoice already submitted."
      redirect_to @sp_invoice.job
    end

    add_crumb "Submit Invoice"
  end

  def create
    @sp_invoice = SpInvoice.new(sp_invoice_params)
    @job = @sp_invoice.job
    if @sp_invoice.save
      if @job.invoice_company && @job.invoice_company.accounts_admin
        SpInvoiceMailer.delay.notification_email(@job.invoice_company.accounts_admin.id, @job.sp_invoice.id)
      end

      flash[:success] = "Invoice #{@sp_invoice.invoice_number} submitted."
      redirect_to @job
    else
      flash[:success] = "There was a problem submitting invoice. Please try again."
      redirect_to @job
    end
  end

  def edit
    add_crumb "Sp Invoices", sp_invoices_path
    add_crumb @sp_invoice.invoice_number, sp_invoice_path(@sp_invoice)
    add_crumb 'Edit'
  end

  def update
    if @sp_invoice.update(sp_invoice_params)
      @sp_invoice.create_activity :update, owner: current_user
      flash[:success] = "Invoice #{@sp_invoice.invoice_number} was successfully updated."
      redirect_to(:action => 'show', :id => @sp_invoice.id, :referrer => "updated")
    else
      render action: 'edit'
    end
  end

  def process_sp_invoice
    @sp_invoice = SpInvoice.find(params[:sp_invoice_id])
    if @sp_invoice.update(status: 'processed')
      @sp_invoice.create_activity :process, owner: current_user
      flash[:success] = "Invoice #{@sp_invoice.invoice_number} marked as processed."
      redirect_to(:action => 'show', :id => @sp_invoice.id, :referrer => "updated")
    else
      render action: 'show'
    end
  end

  def destroy
    @sp_invoice.destroy
    flash[:success] = "Invoice #{@sp_invoice.invoice_number} deleted."
    redirect_to sp_invoices_url
  end

  private
    def set_sp_invoice
      @sp_invoice = SpInvoice.find(params[:id])
    end

    def sp_invoice_params
      params.require(:sp_invoice).permit(
        :job_id,
        :job_type,
        :invoice_number,
        :status,
        :upload,
        :delete_upload
      )
      
    end
end
