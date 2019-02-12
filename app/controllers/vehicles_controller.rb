class VehiclesController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource :except => ['hire_vehicles', 'schedule', 'notes']

  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]

  add_crumb("Vehicles") { |instance| instance.send :vehicles_path }

  def index
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Vehicle").take(100)
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]
    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
      add_crumb('Vehicles') { |instance| instance.send :vehicles_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: VehiclesDatatable.new(view_context, current_user, params[:mode]) }
    end
  end

  def hire_vehicles_data
    @vehicles = Vehicle.where(:exclude_from_schedule => [nil, false]).joins(:hire_details).where('active')
  end

  def hire_agreement_data
    authorize! :read_hire_agreement_data, Vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
    @hire_agreements = @vehicle.hire_agreements
  end

  def workorder_data
    authorize! :read_workorder_data, Vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
    @workorders = @vehicle.workorders
  end

  def build_order_data
    authorize! :read_build_order_data, Vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
    @build_orders = @vehicle.build.build_orders if @vehicle.build
  end

  def off_hire_job_data
    authorize! :read_off_hire_job_data, Vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
    @off_hire_jobs = OffHireJob.joins(off_hire_report: [hire_agreement: :vehicle]).where(vehicles: {id: @vehicle.id})
  end

  def hire_vehicles
    authorize! :read_hire_vehicles, Vehicle

    respond_to do |format|
      format.html {
        add_crumb 'Hire Vehicles'
      }
      format.json {
        #@vehicles = Vehicle.joins(:hire_details).where('active')
        render json: VehiclesDatatable.new(view_context, current_user, params[:mode])
      }
    end
  end

  def schedule
    authorize! :read_schedule, Vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])

    add_crumb @vehicle.name, vehicle_path(@vehicle)
    add_crumb "Schedule"
  end

  def notes
    authorize! :manage_notes, Vehicle
    @vehicle = Vehicle.find(params[:vehicle_id])
  end

  def show
    session['last_request'] = "/vehicles/#{@vehicle.id}"
    @activities = PublicActivity::Activity.order("created_at desc").where(:trackable_type => "Vehicle", :trackable_id => @vehicle.id)
    @notifications = @vehicle.notifications.includes(:notification_type)
    unless current_user.has_role? :admin
      @vehicle.create_activity :view, owner: current_user
    end

    add_crumb @vehicle.name
  end

  def new
    @vehicle = Vehicle.new
    add_crumb 'New'
  end

  def create
    @vehicle = Vehicle.new(vehicle_params.merge(status: 'available', status_date: Date.today))
    if @vehicle.save
      # @hire_vehicle = HireVehicle.create(:vehicle => @vehicle)
      VehicleManager.finalise_new_vehicle(@vehicle, current_user)
      SearchTag.update_tag_list('vehicle', vehicle_params[:tags])
      flash[:success] = "Vehicle created."
      redirect_to @vehicle
    else
      flash[:error] = 'Vehicle create was unsuccessful.'
      render('new')
    end
  end

  def edit
    add_crumb @vehicle.name, vehicle_path(@vehicle)
    add_crumb 'Edit'
  end

  def update
    if @vehicle.update_attributes(vehicle_params)
      VehicleManager.finalise_vehicle_update(@vehicle, current_user)
      SearchTag.update_tag_list('vehicle', vehicle_params[:tags])
      flash[:success] = "Vehicle updated."
      redirect_to(:action => 'show')
    else
      flash[:error] = 'Vehicle update was unsuccessful.'
      render('edit')
    end
  end

  def destroy
    @vehicle.destroy
    flash[:success] = "Vehicle deleted."
    redirect_to(:action => 'index')
  end

private

    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    def vehicle_params
      params.require(:vehicle).permit(
        :vehicle_model_id,
        :model_year,
        :supplier_id,
        :owner_id,
        :class_type,
        :call_sign,
        :build_number,
        :stock_number,
        :vin_number,
        :vehicle_number,
        :engine_number,
        :transmission,
        :mod_plate,
        :odometer_reading,
        :seating_capacity,
        :rego_number,
        :rego_due_date_field,
        :order_number,
        :invoice_number,
        :delivery_date_field,
        :kit_number,
        :license_required,
        :exclude_from_schedule,
        :body_type,
        :build_date,
        :colour,
        :engine_type,
        :tags,
        :status,
        hire_details_attributes: [:daily_km_allowance, :daily_rate, :excess_km_rate, :active],
        attachments_attributes: [
          :vehicle_id,
          :mod_plate,
          :mod_certificate,
          :rego_certificate,
          :photo_front,
          :photo_back,
          :photo_left,
          :photo_right,
          :spec_sheet,
          :vin_plate,
          :pre_delivery_sheet,
          :bma_spec_sheet,
          :wheel_alignment_record,
          :ppsr_register,
          :rigid_bus_inspection_sheet
        ]
      )
    end

end
