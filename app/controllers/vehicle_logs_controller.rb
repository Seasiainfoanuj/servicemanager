class VehicleLogsController < ApplicationController

  before_action :authenticate_user!
  load_and_authorize_resource :except => ['complete_from_workorder']

  before_action :set_vehicle_log, only: [:show, :edit, :update, :complete_from_workorder, :destroy]

  def index
    @filtered_user = User.find(params[:filtered_user_id]) if params[:filtered_user_id]

    if @filtered_user
      add_crumb "Users", users_path
      add_crumb @filtered_user.name, user_path(@filtered_user)
    end

    if current_user.has_role? :admin 
      if params[:vehicle_id]
        @vehicle = Vehicle.find(params[:vehicle_id])
      end
    end

    if params[:vehicle_id]
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle) unless @vehicle.nil? || @vehicle.name.nil?
      add_crumb("Log Entries") { |instance| instance.send :workorders_path }
    else
      add_crumb("Log Entries") { |instance| instance.send :workorders_path }
    end

    respond_to do |format|
      format.html
      format.json { render json: VehicleLogsDatatable.new(view_context, current_user) }
    end
  end

  def show
    if params[:vehicle_id]
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
      add_crumb "Log Entries", vehicle_logs_path(:vehicle_id => @vehicle.id)
      add_crumb @vehicle_log.uid
    else
      add_crumb "Log Entries", vehicle_logs_path
      add_crumb @vehicle_log.uid
    end
  end

  def new
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @vehicle_log = VehicleLog.new(:vehicle_id => @vehicle.id)
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
      add_crumb "Log Entries", vehicle_logs_path(:vehicle_id => @vehicle.id)
      add_crumb "New"
    else
      @vehicle_log = VehicleLog.new
      add_crumb "Log Entries", vehicle_logs_path
      add_crumb "New"
    end
  end

  def create
    @vehicle_log = VehicleLog.new(vehicle_log_params)
    @vehicle_log.uid = 'LOG-' + (0...2).map{ ('A'..'Z').to_a[rand(26)] }.join + (0...4).map{ (1..9).to_a[rand(9)] }.join if @vehicle_log.uid == nil
    if @vehicle_log.save
      if @vehicle_log.odometer_reading
        @vehicle_log.vehicle.update_attributes(:odometer_reading => @vehicle_log.odometer_reading)
        flash[:notice] = "Vehicle odometer reading updated."
      end
      flash[:success] = "Vehicle Log created."
      redirect_to(:action => 'edit', :id => @vehicle_log.id, :vehicle_id => @vehicle_log.vehicle.id)
    else
      render('new')
    end
  end

  def edit
    if params[:vehicle_id]
      add_crumb "Vehicles", vehicles_path
      add_crumb @vehicle.name, vehicle_path(@vehicle)
      add_crumb "Log Entries", vehicle_logs_path(:vehicle_id => @vehicle.id)
      add_crumb @vehicle_log.uid, vehicle_log_path(@vehicle_log, :vehicle_id => @vehicle.id)
      add_crumb "Edit"
    else
      add_crumb "Log Entries", vehicle_logs_path
      add_crumb @vehicle_log.uid, vehicle_log_path(@vehicle_log)
      add_crumb "Edit"
    end
  end

  def update
    if @vehicle_log.update_attributes(vehicle_log_params)
      if @vehicle_log.odometer_reading.present?
        if @vehicle_log.odometer_reading.to_i >= @vehicle_log.vehicle.odometer_reading.to_i
          @vehicle_log.vehicle.odometer_reading = @vehicle_log.odometer_reading
          flash[:notice] = "Vehicle odometer reading updated." if @vehicle_log.vehicle.save
        end
      end

      if @vehicle_log.workorder && @vehicle_log.workorder.manager && @vehicle_log.flagged == true
        VehicleLogMailer.delay.notification_email(@vehicle_log.workorder.manager.id, @vehicle_log.id)
      end

      flash[:success] = "Vehicle Log updated."
      if current_user.has_role? :admin
        redirect_to(:action => 'show', :id => @vehicle_log.id, :vehicle_id => @vehicle_log.vehicle.id)
      else
        redirect_to(:action => 'show', :id => @vehicle_log.id)
      end
    else
      render('edit')
    end
  end

  def complete_from_workorder
    authorize! :complete, @vehicle_log.workorder

    if @vehicle_log.update_attributes(vehicle_log_params)
      if @vehicle_log.odometer_reading.present?
        if @vehicle_log.odometer_reading.to_i >= @vehicle_log.vehicle.odometer_reading.to_i
          @vehicle_log.vehicle.odometer_reading = @vehicle_log.odometer_reading
          flash[:notice] = "Vehicle odometer reading updated." if @vehicle_log.vehicle.save
        end
      end

      if @vehicle_log.workorder && @vehicle_log.workorder.manager && @vehicle_log.flagged == true
        VehicleLogMailer.delay.notification_email(@vehicle_log.workorder.manager.id, @vehicle_log.id)
      end

      flash[:success] = "Vehicle Log updated."
      redirect_to(:controller => 'workorders', :action => 'complete_step2', :workorder_id => @vehicle_log.workorder.id)
    else
      render('edit')
    end
  end

  def destroy
    @vehicle_log.destroy
    flash[:success] = "Vehicle Log deleted."
    redirect_to(:controller => 'vehicle_logs', :action => 'index', :vehicle_id => @vehicle_log.vehicle.id)
  end

private

  def set_vehicle_log
    if params[:vehicle_id]
      @vehicle = Vehicle.find(params[:vehicle_id])
      @vehicle_log = VehicleLog.find(params[:id])
    else
      @vehicle_log = VehicleLog.find(params[:id])
    end
  end

  def vehicle_log_params
    params.require(:vehicle_log).permit(
      :vehicle_id,
      :workorder_id,
      :uid,
      :service_provider_id,
      :name,
      :odometer_reading,
      :attachments,
      :flagged,
      :follow_up_message,
      :details
    )
  end

end
