class StockRequestsController < ApplicationController
  before_action :authenticate_user!
  load_resource :find_by => :uid
  authorize_resource

  before_action :set_stock_request, only: [:show, :edit, :update, :destroy]

  add_crumb("Stock Requests") { |instance| instance.send :stock_requests_path }

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Stock Requests') { |instance| instance.send :stock_requests_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: StockRequestsDatatable.new(view_context, current_user) }
    end
  end

  def show
    @activities = PublicActivity::Activity.order("created_at desc")
                                          .where(:trackable_type => "StockRequest",
                                                 :trackable_id => @stock_request.id)

    if current_user.has_role? :supplier
      unless @stock_request.status == "closed"
        @stock_request.update(status: "viewed")
        @stock_request.create_activity :view, owner: current_user
      end
    end

    add_crumb @stock_request.uid
  end

  def new
    @stock_request = StockRequest.new
    add_crumb "New"
  end

  def edit
    add_crumb @stock_request.uid, stock_request_path(@stock_request)
    add_crumb 'Edit'
  end

  def create
    @stock_request = StockRequest.new(stock_request_params)
    @stock_request.uid = 'SR-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join if @stock_request.uid == nil
    @stock_request.status = "pending"

    respond_to do |format|
      if @stock_request.save
        @stock_request.create_activity :create, owner: current_user
        format.html { redirect_to @stock_request, notice: 'Stock request was successfully created.' }
        format.json { render action: 'show', status: :created, location: @stock_request }
      else
        format.html { render action: 'new' }
        format.json { render json: @stock_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @stock_request.status = "updated"
    respond_to do |format|
      if @stock_request.update(stock_request_params)
        @stock_request.create_activity :update, owner: current_user
        format.html { redirect_to @stock_request, notice: 'Stock request was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stock_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def complete
    authorize! :complete, StockRequest
    @stock_request = StockRequest.find_by_uid!(params[:stock_request_id])
    @stock = Stock.new(stock_request: @stock_request, supplier_id: @stock_request.supplier_id)

    add_crumb @stock_request.uid, stock_request_path(@stock_request)
    add_crumb 'Complete'
  end

  def create_stock
    authorize! :create_stock, StockRequest
    @stock_request = StockRequest.find_by_uid!(params[:stock_request_id])
    @stock = Stock.new(
      params.require(:stock).permit(
        :supplier_id,
        :vehicle_model_id,
        :stock_number,
        :vin_number,
        :engine_number,
        :transmission,
        :eta_date_field
      )
    )
    if @stock.save
      @stock_request.update(stock_id: @stock.id, status: "closed")
      flash[:success] = "Stock request fulfilled and stock item created."
      redirect_to @stock
    else
      render action: 'complete'
    end
  end

  def destroy
    @stock_request.destroy
    respond_to do |format|
      format.html { redirect_to stock_requests_url }
      format.json { head :no_content }
    end
  end

  def send_notifications
    authorize! :send_notifications, StockRequest

    @stock_request = StockRequest.find(params[:stock_request_id])
    @message = params[:message]

    StockRequestMailer.delay.notification_email(@stock_request.supplier.id, @stock_request.id, @message)
    @stock_request.create_activity :send, recipient: @stock_request.supplier, owner: current_user

    @stock_request.update(status: "sent")

    flash[:success] = "Stock request sent to #{@stock_request.supplier.email}"
    redirect_to(:action => 'show', :id => @stock_request.uid)
  end

  private
    def set_stock_request
      @stock_request = StockRequest.find_by_uid!(params[:id])
    end

    def stock_request_params
      params.require(:stock_request).permit(
        :uid,
        :invoice_company_id,
        :supplier_id,
        :customer_id,
        :stock_id,
        :vehicle_make,
        :vehicle_model,
        :transmission_type,
        :requested_delivery_date_field,
        :details
      )
    end
end
