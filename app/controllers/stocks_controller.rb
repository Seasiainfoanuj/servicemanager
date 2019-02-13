class StocksController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource

  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  add_crumb('Allocated Stock') { |instance| instance.send :stocks_path }

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Stock') { |instance| instance.send :stocks_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: StocksDatatable.new(view_context, current_user) }
    end
  end

  def show
    add_crumb @stock.name, @stocks
  end

  def new
    @stock = Stock.new
    add_crumb 'New'
  end

  def create
    @stock = Stock.new(stock_params)
    if @stock.vin_number.present? && Vehicle.exists?(vin_number: @stock.vin_number)
      flash[:error] = "Invalid VIN Number - already assigned to a vehicle"
      render('new') and return
    end  
    @stock.supplier_id = current_user.id if current_user.has_role? :supplier
    if @stock.save
      flash[:success] = "Stock item added."
      redirect_to(:action => 'index')
    else
      flash[:error] = "Create new stock was unsuccessful."  
      render('new')
    end
  end

  def edit
    add_crumb @stock.name, stock_path(@stock)
    add_crumb 'Edit'
  end

  def update
    if stock_params[:vin_number].present? && Vehicle.exists?(vin_number: stock_params[:vin_number])
      flash[:error] = "Invalid VIN Number - already assigned to a vehicle"
      render('edit') and return
    end  
    if @stock.update_attributes(stock_params)
      flash[:success] = "Stock update was successful."
      redirect_to(:action => 'index') and return
    else
      flash[:error] = "Stock update was unsuccessful."  
      render('edit') and return
    end
  end

  def destroy
    @stock.destroy
    flash[:success] = "Stock deleted."
    redirect_to(:action => 'index')
  end

  def convert_to_vehicle
    @stock = Stock.find(params[:id])
    @vehicle = Vehicle.new(
      :vehicle_model_id => @stock.vehicle_model_id,
      :supplier_id => @stock.supplier_id,
      :stock_number => @stock.number,
      :vin_number => @stock.vin_number,
      :engine_number => @stock.engine_number,
      :transmission => @stock.transmission,
      :status => 'available'
    )
    if @vehicle.save
      @hire_vehicle = HireVehicle.create(:vehicle => @vehicle)
      @stock.destroy
      flash[:success] = "Stock item converted to vehicle."
      redirect_to(:controller => 'vehicles', :action => 'edit', :id => @vehicle.id)
    else
      flash[:error] = "Unable to convert Stock to vehicle."
      render('index')
    end
  end

private

  def set_stock
    @stock = Stock.find(params[:id])
  end

  def stock_params
    params.require(:stock).permit(
      :supplier_id,
      :vehicle_model_id,
      :stock_number,
      :vin_number,
      :engine_number,
      :transmission,
      :eta_date_field,
      :colour
    )
  end
end
