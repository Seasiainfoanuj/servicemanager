class PoRequestsController < ApplicationController
  before_action :authenticate_user!
  load_resource :find_by => :uid
  authorize_resource

  before_action :set_po_request, only: [:show, :edit, :update, :destroy]

  add_crumb("PO Requests") { |instance| instance.send :po_requests_path }

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('PO Requests') { |instance| instance.send :po_requests_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: PoRequestsDatatable.new(view_context, current_user) }
    end
  end

  def show
     if  current_user.has_role? :admin
      @activities = PublicActivity::Activity.order("created_at desc")
                                          .where(:trackable_type => "PoRequest",
                                                 :trackable_id => @po_request.id)

      unless params[:referer] == "update"
        unless @po_request.read == true
          @po_request.update(read: true)
          @po_request.create_activity :read, owner: current_user
        end
      end
     end

    add_crumb @po_request.uid
  end

  def new
    @po_request = PoRequest.new
    add_crumb "New"
  end

  def create
    @po_request = PoRequest.new(po_request_params)
    @po_request.uid = 'PO-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join unless @po_request.uid.present?
    @po_request.read = false
    @po_request.status = 'new'

    if @po_request.save
      @po_request.create_activity :create, owner: current_user
      flash[:success] = "PO request created."
      redirect_to @po_request
    else
      render('new')
    end
  end

  def edit
    add_crumb @po_request.uid, po_request_path(@po_request)
    add_crumb 'Edit'
  end

  def update
    if @po_request.update_attributes(po_request_params)
      @po_request.create_activity :update, owner: current_user
      flash[:success] = "PO request updated."
      redirect_to action: 'show', id: @po_request.uid, referer: "update"
    else
      render('edit')
    end
  end

  def destroy
    if @po_request.destroy
      flash[:success] = "PO request deleted."
    end
    redirect_to(:action => 'index')
  end

  def send_notification
    authorize! :send_notification, PoRequest

    @po_request = PoRequest.find(params[:po_request_id])
    @message = params[:message]

    PoRequestMailer.delay.notification_email(@po_request.service_provider_id, current_user.id, @po_request.id, @message)
    @po_request.create_activity :send, recipient: @po_request.service_provider, owner: current_user

    flash[:success] = "PO request sent to #{@po_request.service_provider.email}"
    redirect_to(:action => 'show', :id => @po_request.uid)
  end

  private
    def set_po_request
      @po_request = PoRequest.find_by_uid!(params[:id])
    end

    def po_request_params
      params.require(:po_request).permit(
        :vehicle_id,
        :workorder_id,
        :service_provider_id,
        :uid,
        :vehicle_make,
        :vehicle_model,
        :vehicle_vin_number,
        :sched_date_field,
        :sched_time_field,
        :etc_date_field,
        :etc_time_field,
        :read,
        :flagged,
        :status,
        :details,
        :tag_list,
        uploads_attributes: [:id, :po_request_id, :upload, :_destroy]
      )
    end
end
