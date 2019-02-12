class VehicleMakesController < ApplicationController

  before_action :authenticate_user!
  authorize_resource

  before_action :set_vehicle_make, only: [:edit, :update, :destroy]

  add_crumb("Vehicle Makes") { |instance| instance.send :vehicle_makes_path }

  def index
    @vehicle_makes = VehicleMake.all
    #@vehicle_makes = VehicleMake.order('position ASC')
  end

  def new
    @vehicle_make = VehicleMake.new
    add_crumb 'New'
  end

  def create
    @vehicle_make = VehicleMake.new(vehicle_make_params)
    if @vehicle_make.save
      flash[:success] = "Vehicle make added."
      redirect_to(:action => 'index')
    else
      render('new')
    end
  end

  def edit
    add_crumb @vehicle_make.name, @vehicle_makes
    add_crumb 'Edit'
  end

  def update
    if @vehicle_make.update(vehicle_make_params)
      flash[:success] = "Vehicle make updated."
      redirect_to(:action => 'index')
    else
      render('edit')
    end
  end

  def destroy
    @vehicle_make.destroy
    flash[:success] = "Vehicle make deleted."
    redirect_to(:action => 'index')
  end

private

  def set_vehicle_make
    @vehicle_make = VehicleMake.find(params[:id])
  end

  def vehicle_make_params
    params.require(:vehicle_make).permit(
      :name
    )
  end

end
