class SalesOrdersController < ApplicationController
  before_action :authenticate_user_from_token!, only: [:show]
  before_action :authenticate_user!
  load_resource :find_by => :number
  authorize_resource

  before_action :set_sales_order, only: [:show, :edit, :update, :destroy]

  add_crumb("Sales Orders") { |instance| instance.send :sales_orders_path }

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Sales Orders') { |instance| instance.send :sales_orders_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: SalesOrdersDatatable.new(view_context, current_user) }
    end
  end

  def show
    @activities = PublicActivity::Activity.order("created_at desc")
                                          .where(:trackable_type => "SalesOrder",
                                                 :trackable_id => @sales_order.id)


    @sales_order.create_activity :view, owner: current_user if current_user == @sales_order.customer

    add_crumb @sales_order.number
  end

  def new
    @sales_order = SalesOrder.new(order_date: Date.today)
    @sales_order.number = SalesOrder.last.number.next if SalesOrder.last

    if params[:quote_id].present?
      quote = Quote.find(params[:quote_id])
      @sales_order.quote = quote
      @sales_order.customer = quote.customer
      @sales_order.manager = quote.manager if quote.manager
      @sales_order.invoice_company = quote.invoice_company
    end

    add_crumb "New"
  end

  def create
    @sales_order = SalesOrder.new(sales_order_params)
    if @sales_order.save
      @sales_order.create_activity :create, owner: current_user
      flash[:success] = "Sales order created."
      redirect_to @sales_order
    else
      render 'new'
    end
  end

  def edit
    add_crumb @sales_order.number, sales_order_path(@sales_order)
    add_crumb 'Edit'
  end

  def update
    if @sales_order.update(sales_order_params)
      @sales_order.create_activity :update, owner: current_user
      flash[:success] = "Sales order updated."
      redirect_to @sales_order
    else
      render('edit')
    end
  end

  def destroy
    @sales_order.destroy
    flash[:success] = "Sales order deleted."
    redirect_to(:action => 'index')
  end

  def send_notification
    authorize! :send_notification, SalesOrder

    @sales_order = SalesOrder.find(params[:sales_order_id])
    @message = params[:message]

    SalesOrderMailer.delay.notification_email(@sales_order.customer_id, current_user.id, @sales_order.id, @message)
    @sales_order.create_activity :send, recipient: @sales_order.customer, owner: current_user

    flash[:success] = "Sales order sent to #{@sales_order.customer.email}"
    redirect_to @sales_order
  end

  private
    def authenticate_user_from_token!
      user_email = params[:user_email].presence
      user       = user_email && User.find_by_email(user_email)
      if params[:id].presence
        sales_order_id = params[:id]
      elsif params[:sales_order_id].presence
        sales_order_id = params[:sales_order_id]
      end
      sales_order = sales_order_id && user_email && User.find_by_email(user_email).orders.find_by_number(sales_order_id)
      if user && sales_order && Devise.secure_compare(user.authentication_token, params[:user_token])
        sign_in user, store: false
      end
    end

    def set_sales_order
      @sales_order = SalesOrder.find_by_number!(params[:id])
    end

    def sales_order_params
      params.require(:sales_order).permit(
        :number,
        :order_date_field,
        :order_date,
        :sales_order_id,
        :quote_id,
        :build_id,
        :customer_id,
        :manager_id,
        :invoice_company_id,
        :deposit_required,
        :deposit_required_cents,
        :deposit_received,
        :details,
        milestones_attributes: [
          :id,
          :sales_order_id,
          :milestone_date_field,
          :milestone_time_field,
          :description,
          :completed,
          :_destroy
        ]
      )
    end
end
